package com.example.flutterphotometa.plugins

import com.example.flutterphotometa.protobuf.FlutterPlugins
import com.example.flutterphotometa.protobuf.PhotoApis
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertEquals
import org.junit.Test
import java.nio.ByteBuffer


class BinaryMessengerTest : BinaryMessenger {

    var map = hashMapOf<String, BinaryMessenger.BinaryMessageHandler>()

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?
    ) {
        handler?.let {
            this.map.put(channel, handler)
            handler
        } ?: let {
            this.map.remove(channel)
        }
    }

    override fun send(channel: String, bufferMsg: ByteBuffer?) {
        this.send(channel, bufferMsg, null)
    }

    override fun send(
        channel: String,
        bufferMsg: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

}

class CustomCodecHandlerTest {

    @Test
    fun testSimpleDecodeMethodCall() {
        val testArgumentInt = 100
        Plugins.instance(null).register(FlutterPlugins.ValidMethod.GET_PHOTO) { a: Int?, _, r ->
            assertEquals(testArgumentInt, a)
            r.success(a?.times(10))
        }

        val channel = "com.sample.channel.test"
        val bmt = BinaryMessengerTest()
        MethodChannel(bmt, channel, Plugins.instance(null)).setMethodCallHandler(Plugins.instance(null))

        val bb = ReaderWriterBuffer.writer()
            .writeByte(0)
            .writeValue(FlutterPlugins.ValidMethod.GET_PHOTO.number)
            .writeValue(testArgumentInt)
            .seal()

        bmt.map[channel]!!.onMessage(bb) {
            val reader = ReaderWriterBuffer.reader(it!!)
            assertEquals(0.toByte(), reader.readByte())
            assertEquals(testArgumentInt * 10, reader.readValue<Int>())
            assert(!reader.hasMore())
        }
    }

    @Test
    fun testMessageDecodeMethodCall() {
        val photo = PhotoApis.Photo.newBuilder()
            .setFileSize(100)
            .setHeight(1000)
            .setWidth(1200)
            .setName("DCMP-2019.JPEG")
            .setLocalIdentifier("5fad177c-0205-42d5-8964-8741b15f9a97")
            .build()
        val photoMeta = PhotoApis.PhotoMetadata.newBuilder()
            .setCaptureAt(100)
            .setLocation(PhotoApis.Location.newBuilder().setLatitude(1.0).setLongitude(11.0).build())
            .setMake("Canon")
            .build()

        Plugins.instance(null).register(
            FlutterPlugins.ValidMethod.GET_PHOTO_METADATA,
            { PhotoApis.Photo.parseFrom(it) }) { a: PhotoApis.Photo?, _, r ->
            assertEquals(photo, a)
            r.success(photoMeta)
        }

        val channel = "com.sample.channel.test"
        val bmt = BinaryMessengerTest()
        MethodChannel(bmt, channel, Plugins.instance(null)).setMethodCallHandler(Plugins.instance(null))

        val bb = ReaderWriterBuffer.writer()
            .writeByte(0)
            .writeValue(FlutterPlugins.ValidMethod.GET_PHOTO_METADATA.number)
            .writeValue(photo)
            .seal()

        bmt.map[channel]!!.onMessage(bb) {
            val reader = ReaderWriterBuffer.reader(it!!)
            assertEquals(0.toByte(), reader.readByte())
            assertEquals(
                photoMeta,
                reader.readValue { bytes -> PhotoApis.PhotoMetadata.parseFrom(bytes) })
            assert(!reader.hasMore())
        }
    }

}