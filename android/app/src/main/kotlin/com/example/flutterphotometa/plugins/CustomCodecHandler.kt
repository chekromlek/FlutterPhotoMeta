package com.example.flutterphotometa.plugins

import android.content.Context
import com.example.flutterphotometa.protobuf.FlutterPlugins
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCodec
import java.nio.ByteBuffer


/**
 *
 */
class CustomMethodCall<T>(val method: FlutterPlugins.ValidMethod, val arguments: T?)

/**
 *
 */
class PlatformException(val code: String, message: String?, val detail: Any?) :
    RuntimeException(message)

/**
 *
 */
typealias Function<T> = (T?, Context?, MethodChannel.Result) -> Unit

/**
 *
 */
typealias CustomMethodCallCreator<T> = (BufferReader) -> CustomMethodCall<T>

/**
 *
 */
class Plugins(val context: Context?) : MethodChannel.MethodCallHandler, MethodCodec {

    private var registries = HashMap<FlutterPlugins.ValidMethod, Any>()
    private var methodCallCreator =
        HashMap<FlutterPlugins.ValidMethod, CustomMethodCallCreator<*>>()

    companion object Factory {

        private var sharedInstance: Plugins? = null

        fun instance(context: Context?): Plugins {
            if (sharedInstance == null) {
                sharedInstance = Plugins(context)
            }
            return sharedInstance!!
        }
    }

    fun <T> register(method: FlutterPlugins.ValidMethod, func: Function<T>): Plugins {
        return this.register(method, { null }, func)
    }

    fun <T> register(
        method: FlutterPlugins.ValidMethod,
        creator: ProtoMessageCreator<T>? = { null },
        func: Function<T>
    ): Plugins {
        this.registries[method] = func
        this.methodCallCreator[method] = { reader ->
            CustomMethodCall(method, reader.readValue(creator))
        }
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.arguments) {
            is CustomMethodCall<*> -> {
                val cmc = methodCall.arguments as CustomMethodCall<*>
                @Suppress("UNCHECKED_CAST")
                this.registries[cmc.method]?.let { (it as Function<*>)(cmc.arguments, this.context, result) }!!
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun decodeMethodCall(buffer: ByteBuffer?): MethodCall {
        val reader = (buffer?.let { ReaderWriterBuffer.reader(it) })!!
        val flag = reader.readByte()
        assert(flag <= 1)
        return when (flag) {
            0.toByte() -> {
                val method = reader.readValue<Int>()?.let {
                    FlutterPlugins.ValidMethod.forNumber(it)
                }
                MethodCall("", method?.let {
                    this.methodCallCreator[method]?.let { creator -> creator(reader) }
                })
            }
            else -> {
                MethodCall(reader.readValue(), reader.readValue())
            }
        }
    }

    override fun encodeErrorEnvelope(code: String?, message: String?, detail: Any?): ByteBuffer {
        val writer = ReaderWriterBuffer.writer()
        return writer.writeByte(1).writeValue(code).writeValue(message).writeValue(detail).seal()
    }

    override fun encodeMethodCall(methodCall: MethodCall?): ByteBuffer {
        val writer = ReaderWriterBuffer.writer()
        return when (methodCall?.arguments) {
            is CustomMethodCall<*> -> {
                val cmc = methodCall.arguments as CustomMethodCall<*>
                writer.writeByte(0).writeValue(cmc.method.number.toByte()).writeValue(cmc.arguments)
                    .seal()
            }
            else -> {
                writer.writeByte(1).writeValue(methodCall!!.method).writeValue(methodCall.arguments)
                    .seal()
            }
        }
    }

    override fun encodeSuccessEnvelope(value: Any?): ByteBuffer {
        val writer = ReaderWriterBuffer.writer()
        return writer.writeByte(0).writeValue(value).seal()
    }

    override fun decodeEnvelope(buffer: ByteBuffer?): Any {
        assert(buffer != null) { "Expected envelope, got nothing" }
        assert(buffer!!.capacity() == 0) { "Expected envelope, got nothing" }
        val reader = ReaderWriterBuffer.reader(buffer)
        val flag = reader.readByte()
        assert(flag <= 1) { "Corrupted envelop message" }
        return when (flag) {
            0.toByte() -> {
                reader.readValue<Any>()!!
            }
            else -> {
                // decode error message
                val code = reader.readValue<String>()
                val message = reader.readValue<String>()
                val detail = reader.readValue<String>()
                assert(code != null) { "Invalid envelope" }
                throw PlatformException(code!!, message, detail)
            }
        }
    }

}
