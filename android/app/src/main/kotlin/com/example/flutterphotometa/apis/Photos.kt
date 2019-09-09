package com.example.flutterphotometa.apis

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.os.Build
import androidx.exifinterface.media.ExifInterface
import com.example.flutterphotometa.MainActivity
import com.example.flutterphotometa.plugins.Function
import com.example.flutterphotometa.protobuf.PhotoApis
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.text.SimpleDateFormat
import java.util.*


/**
 *
 */
fun calculateInSampleSize(srcWidth: Int, srcHeight: Int, reqWidth: Int, reqHeight: Int): Int {
    // Raw height and width of image
    var inSampleSize = 1

    if (reqHeight != 0 && reqWidth != 0 && (srcHeight > reqHeight || srcWidth > reqWidth)) {

        val halfHeight: Int = srcHeight / 2
        val halfWidth: Int = srcWidth / 2

        // Calculate the largest inSampleSize value that is a power of 2 and keeps both
        // height and width larger than the requested height and width.
        while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
            inSampleSize *= 2
        }
    }

    return inSampleSize
}

/**
 *
 */
fun loadLocalImage(file: String, width: Int, height: Int): Bitmap? {
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
        BitmapFactory.Options().run {
            inJustDecodeBounds = true
            BitmapFactory.decodeFile(file, this)

            inSampleSize = calculateInSampleSize(this.outWidth, this.outHeight, width, height)
            inJustDecodeBounds = false
            BitmapFactory.decodeFile(file, this)
        }
    } else {
        ImageDecoder.decodeBitmap(ImageDecoder.createSource(File(file))) { decoder, info, src ->
            decoder.setTargetSampleSize(
                calculateInSampleSize(
                    info.size.width,
                    info.size.height,
                    width,
                    height
                )
            )
        }
    }
}

/**
 *
 */
val GetPhoto: Function<PhotoApis.Photo> = fun(
    arg: PhotoApis.Photo?, ctx: Context?, result: MethodChannel.Result
) {
    arg?.let {
        if (it.width == 0 || it.height == 0) {
            val handler: IOHandler<PhotoApis.Photo, ByteArray> = { p ->
                File(p!!.localIdentifier).readBytes()
            }
            (ctx as MainActivity).performCoroutine(it, result, handler)
        } else {
            val handler: IOHandler<PhotoApis.Photo, ByteArray> = { p ->
                val bitmap = loadLocalImage(p!!.localIdentifier, p.width, p.height)
                if (bitmap == null) {
                    null
                } else {
                    val baos = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 75, baos)
                    baos.toByteArray()
                }
            }
            (ctx as MainActivity).performCoroutine(it, result, handler)
        }
        return
    }
    result.error("IMARG", "Invalid argument", null)
}

/**
 *
 */
val GetPhotoMetadata: Function<PhotoApis.Photo> = fun(
    arg: PhotoApis.Photo?, _: Context?, result: MethodChannel.Result
) {
    arg?.let {
        val exf = ExifInterface(it.localIdentifier)
        val builder = PhotoApis.PhotoMetadata.newBuilder()
        exf.latLong?.let { latLong ->
            val lbuilder = PhotoApis.Location.newBuilder()
            lbuilder.latitude = latLong[0]
            lbuilder.longitude = latLong[0]
            builder.setLocation(lbuilder.build())
        }
        exf.getAttribute(ExifInterface.TAG_MAKE)?.let { make -> builder.setMake(make) }
        exf.getAttribute(ExifInterface.TAG_DATETIME_DIGITIZED)?.let { date ->
            val dateFormatter = SimpleDateFormat("yyyy:MM:dd hh:mm:ss", Locale.getDefault())
            builder.captureAt = dateFormatter.parse(date).time
        }
        builder.fileSize = it.fileSize
        result.success(builder.build())
        return
    }
    result.error("IMARG", "Invalid argument", null)
}

/**
 *
 */
val RemovePhotoMetadata: Function<PhotoApis.Photo> = fun(
    arg: PhotoApis.Photo?, _: Context?, result: MethodChannel.Result
) {
    arg?.let {
        val exf = ExifInterface(it.localIdentifier)
        exf.setLatLong(0.0, 0.0)
        exf.setAttribute(ExifInterface.TAG_MAKE, null)
        exf.setAttribute(ExifInterface.TAG_DATETIME_DIGITIZED, null)
        exf.saveAttributes()
        result.success(true)
        return
    }
    result.error("IMARG", "Invalid argument", null)
}

