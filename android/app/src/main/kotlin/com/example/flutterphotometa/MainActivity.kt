package com.example.flutterphotometa

import android.content.pm.PackageManager
import android.os.Bundle
import com.example.flutterphotometa.apis.*
import com.example.flutterphotometa.plugins.Function
import com.example.flutterphotometa.plugins.Plugins
import com.example.flutterphotometa.protobuf.FlutterPlugins
import com.example.flutterphotometa.protobuf.PhotoApis
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.*


class MainActivity : FlutterActivity(), CoroutineScope by MainScope() {

    private val _channel = "com.example.flutterphotometa/photos"

    private val resultMapping = hashMapOf<Int, Triple<Any?, MethodChannel.Result, Function<*>>>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        val plugin = Plugins.instance(this)
            .register(FlutterPlugins.ValidMethod.LIST_PHOTOS, GetListPhotos)
            .register(
                FlutterPlugins.ValidMethod.GET_PHOTO,
                { PhotoApis.Photo.parseFrom(it) },
                GetPhoto
            )
            .register(
                FlutterPlugins.ValidMethod.GET_PHOTO_METADATA,
                { PhotoApis.Photo.parseFrom(it) },
                GetPhotoMetadata
            )
            .register(
                FlutterPlugins.ValidMethod.REMOVE_PHOTO_METADATA,
                { PhotoApis.Photo.parseFrom(it) },
                RemovePhotoMetadata
            )

        MethodChannel(flutterView, _channel, plugin).setMethodCallHandler(plugin)
    }

    override fun onDestroy() {
        super.onDestroy()
        cancel()
    }

    fun <T, R> performCoroutine(t: T?, r: MethodChannel.Result, handler: IOHandler<T, R>) = launch {
        val result = withContext(Dispatchers.IO) {
            handler(t)
        }
        if (result == null) {
            r.error("UTRP", "Unable execute requesting code", null)
        } else {
            r.success(result)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            100 -> {
                this.resultMapping[requestCode]?.let {
                    if (grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                        @Suppress("UNCHECKED_CAST")
                        (it.third as? Function<Any>)?.let { f ->
                            f(it.first, this, it.second)
                        }
                    } else {
                        it.second.error("URPD", "Permission denied", null)
                    }
                }
            }
        }
    }

    fun <T> registerPermissionMapping(
        requestCode: Int,
        arg: T?,
        result: MethodChannel.Result,
        f: Function<T>
    ) {
        this.resultMapping[requestCode] = Triple(arg, result, f)
    }

}
