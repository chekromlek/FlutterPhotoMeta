package com.example.flutterphotometa.apis

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.provider.MediaStore
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import com.example.flutterphotometa.MainActivity
import com.example.flutterphotometa.plugins.Function
import com.example.flutterphotometa.protobuf.PhotoApis
import io.flutter.plugin.common.MethodChannel


/**
 *
 */
val GetListPhotos: Function<Any> = fun(arg: Any?, ctx: Context?, result: MethodChannel.Result) {

    val f = { _: Any?, inCtx: Context?, inResult: MethodChannel.Result ->
        val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.HEIGHT,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.SIZE
        )
        val dataCursor = inCtx!!.contentResolver.query(uri, projection, null, null, null)

        val dataIndex = dataCursor!!.getColumnIndex(MediaStore.MediaColumns.DATA)
        val nameIndex = dataCursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
        val heightIndex = dataCursor.getColumnIndex(MediaStore.MediaColumns.HEIGHT)
        val widthIndex = dataCursor.getColumnIndex(MediaStore.MediaColumns.WIDTH)
        val sizeIndex = dataCursor.getColumnIndex(MediaStore.MediaColumns.SIZE)

        val photosBuilder = PhotoApis.Photos.newBuilder()

        while (dataCursor.moveToNext()) {
            photosBuilder.addPhotos(
                PhotoApis.Photo.newBuilder()
                    .setLocalIdentifier(dataCursor.getString(dataIndex))
                    .setName(dataCursor.getString(nameIndex) ?: "")
                    .setFileSize(dataCursor.getLong(sizeIndex))
                    .setWidth(dataCursor.getInt(widthIndex))
                    .setHeight(dataCursor.getInt(heightIndex))
                    .build()
            )
        }
        inResult.success(photosBuilder.build())
    }

    if (ContextCompat.checkSelfPermission(ctx!!, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        != PackageManager.PERMISSION_GRANTED
    ) {
        ActivityCompat.requestPermissions(
            ctx as Activity,
            arrayOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ),
            100
        )
        (ctx as MainActivity).registerPermissionMapping(100, arg, result, f)
        return
    }
    f(arg, ctx, result)
}