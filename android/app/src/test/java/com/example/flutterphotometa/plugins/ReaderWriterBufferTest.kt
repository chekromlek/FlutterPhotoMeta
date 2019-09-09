package com.example.flutterphotometa.plugins

import com.example.flutterphotometa.extensions.*
import com.example.flutterphotometa.protobuf.FlutterPlugins
import com.example.flutterphotometa.protobuf.PhotoApis
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Test
import java.nio.ByteBuffer
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class ReaderWriterBufferUnitTest {

    /*** Test Writer ***/

    @Test
    fun testWriteByte() {
        val writer = ReaderWriterBuffer.writer()
        val bs = writer.writeByte(12).done()
        assertEquals(1, bs.size)
        assertEquals(12.toByte(), bs[0])
    }

    @Test
    fun testWriteBytes() {
        val writer = ReaderWriterBuffer.writer()
        val ba = byteArrayOf(11, 12, 13)
        val bs = writer.writeBytes(ba).done()
        assertEquals(ba.size + 4, bs.size)
        assertArrayEquals(ba, bs.copyOfRange(4, 4 + ba.size))
    }

    @Test
    fun testWriterByteBuffer() {
        val writer = ReaderWriterBuffer.writer()
        val ba = byteArrayOf(33, 32, 43, 39)
        val bb = ByteBuffer.wrap(ba)
        val bs = writer.writeByteBuffer(bb).done()
        assertEquals(ba.size + 4, bs.size)
        assertEquals(ba.size, bs.toInt())
        assertArrayEquals(ba, bs.copyOfRange(4, 4 + ba.size))
    }

    @Test
    fun testWriteUTF8() {
        val writer = ReaderWriterBuffer.writer()
        val test = "មាន\u200Bរឿង\u200Bអ្វី\u200Bកើតឡើង? what's happen?"
        val size = test.toByteArray().size
        val bs = writer.writeUTF8(test).done()
        assertEquals(size + 4, bs.size)
        assertEquals(test, String(bs.copyOfRange(4, 4 + size)))
    }

    @Test
    fun testWriteValue() {
        val bools = booleanArrayOf(true, false)
        bools.forEach {
            val writer = ReaderWriterBuffer.writer()
            val bs = writer.writeValue(it).done()
            assertEquals(2, bs.size)
            assertEquals(FlutterPlugins.DataType.BOOL.number.toByte(), bs[0])
            assertEquals(it.toByte(), bs[1])
        }

        var writer = ReaderWriterBuffer.writer()
        val i = 12
        var bs = writer.writeValue(i).done()
        assertEquals(1 + 4, bs.size)
        assertEquals(FlutterPlugins.DataType.INT32.number.toByte(), bs[0])

        writer = ReaderWriterBuffer.writer()
        val l = 120L
        bs = writer.writeValue(l).done()
        assertEquals(1 + 8, bs.size)
        assertEquals(FlutterPlugins.DataType.INT64.number.toByte(), bs[0])
        assertEquals(l, bs.copyOfRange(1, 9).toLong())

        writer = ReaderWriterBuffer.writer()
        val f = 1.0.toFloat()
        bs = writer.writeValue(f).done()
        assertEquals(1 + 8, bs.size)
        assertEquals(FlutterPlugins.DataType.FLOAT64.number.toByte(), bs[0])
        assertEquals(f, bs.copyOfRange(1, 9).toDouble().toFloat())

        writer = ReaderWriterBuffer.writer()
        val d = 1.0
        bs = writer.writeValue(d).done()
        assertEquals(1 + 8, bs.size)
        assertEquals(FlutterPlugins.DataType.FLOAT64.number.toByte(), bs[0])
        assertEquals(d, bs.copyOfRange(1, 9).toDouble(), 0.0)

        writer = ReaderWriterBuffer.writer()
        val str = "មាន\u200Bរឿង\u200Bអ្វី\u200Bកើតឡើង? what's happen?"
        var size = str.toByteArray().size
        bs = writer.writeValue(str).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.STRING.number.toByte(), bs[0])
        assertEquals(size, bs.copyOfRange(1, 5).toInt())
        assertEquals(str, String(bs.copyOfRange(5, 5 + size)))

        writer = ReaderWriterBuffer.writer()
        val ba = byteArrayOf(1, 2, 3, 4)
        bs = writer.writeValue(ba).done()
        assertEquals(1 + 4 + ba.size, bs.size)
        assertEquals(FlutterPlugins.DataType.UINT8LIST.number.toByte(), bs[0])
        assertEquals(ba.size, bs.copyOfRange(1, 5).toInt())
        assertArrayEquals(ba, bs.copyOfRange(5, 5 + ba.size))

        writer = ReaderWriterBuffer.writer()
        val ia = intArrayOf(10, 12, 23, 34)
        size = ia.size * 4
        bs = writer.writeValue(ia).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.INT32LIST.number.toByte(), bs[0])
        assertEquals(ia.size, bs.copyOfRange(1, 5).toInt())
        assertArrayEquals(ia.toBytes(), bs.copyOfRange(5, 5 + size))

        writer = ReaderWriterBuffer.writer()
        val la = longArrayOf(110, 122, 233, 364)
        size = la.size * 8
        bs = writer.writeValue(la).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.INT64LIST.number.toByte(), bs[0])
        assertEquals(la.size, bs.copyOfRange(1, 5).toInt())
        assertArrayEquals(la.toBytes(), bs.copyOfRange(5, 5 + size))

        writer = ReaderWriterBuffer.writer()
        val da = doubleArrayOf(11.10, 12.2, 2.33, 36.4)
        size = da.size * 8
        bs = writer.writeValue(da).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.FLOAT64LIST.number.toByte(), bs[0])
        assertEquals(da.size, bs.copyOfRange(1, 5).toInt())
        assertArrayEquals(da.toBytes(), bs.copyOfRange(5, 5 + size))

        writer = ReaderWriterBuffer.writer()
        val le = ArrayList(listOf(11.10, "test", 100))
        size = le.byteCount()
        bs = writer.writeValue(le).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.LIST.number.toByte(), bs[0])
        assertEquals(le.size, bs.copyOfRange(1, 5).toInt())
        // TODO: test read data back from byte data with the original value using BufferReader

        writer = ReaderWriterBuffer.writer()
        val mke = HashMap(mapOf(1 to 11.10, 2.1 to "test", "key" to 100))
        size = mke.byteCount()
        bs = writer.writeValue(mke).done()
        assertEquals(1 + 4 + size, bs.size)
        assertEquals(FlutterPlugins.DataType.MAP.number.toByte(), bs[0])
        assertEquals(mke.size, bs.copyOfRange(1, 5).toInt())
        // TODO: test read data back from byte data with the original value using BufferReader

        writer = ReaderWriterBuffer.writer()
        val photo = PhotoApis.Photo.newBuilder()
            .setFileSize(100)
            .setHeight(1000)
            .setWidth(1200)
            .setName("DCMP-2019.JPEG")
            .setLocalIdentifier("5fad177c-0205-42d5-8964-8741b15f9a97")
            .build()
        val bytes = photo.toByteArray()
        bs = writer.writeValue(photo).done()
        assertEquals(1 + 4 + bytes.size, bs.size)
        assertEquals(FlutterPlugins.DataType.MESSAGE.number.toByte(), bs[0])
        assertEquals(bytes.size, bs.copyOfRange(1, 5).toInt())
        assertArrayEquals(bytes, bs.copyOfRange(5, 5 + bytes.size))
    }

    /*** Test Reader ***/

    @Test
    fun testReadByte() {
        val bs = ReaderWriterBuffer.writer().writeByte(1).done()
        val reader = ReaderWriterBuffer.reader(ByteBuffer.wrap(bs))
        assertEquals(1.toByte(), reader.readByte())
        assert(!reader.hasMore())
    }

    @Test
    fun testReadBytes() {
        val bytes = byteArrayOf(2, 3, 4, 5)
        val bs = ReaderWriterBuffer.writer().writeBytes(bytes).done()
        val reader = ReaderWriterBuffer.reader(ByteBuffer.wrap(bs))
        assertArrayEquals(bytes, reader.readBytes())
        assert(!reader.hasMore())
    }

    @Test
    fun testReadByteBuffer() {
        val bytes = byteArrayOf(2, 3, 4, 5)
        val bs = ReaderWriterBuffer.writer().writeByteBuffer(ByteBuffer.wrap(bytes)).done()
        val reader = ReaderWriterBuffer.reader(ByteBuffer.wrap(bs))
        assertArrayEquals(bytes, reader.readBytes())
        assert(!reader.hasMore())
    }

    @Test
    fun testReadUTF8() {
        val str = "មាន\u200Bរឿង\u200Bអ្វី\u200Bកើតឡើង? what's happen?"
        val bs = ReaderWriterBuffer.writer().writeUTF8(str).done()
        val reader = ReaderWriterBuffer.reader(ByteBuffer.wrap(bs))
        assertEquals(str, reader.readUTF8())
        assert(!reader.hasMore())
    }

    @Test
    fun testReadValue() {
        val newWriter: () -> BufferWriter = { ReaderWriterBuffer.writer() }

        var reader = ReaderWriterBuffer.reader(newWriter().writeValue(true).done().toByteBuffer())
        assertEquals(true, reader.readValue())
        assert(!reader.hasMore())

        reader = ReaderWriterBuffer.reader(newWriter().writeValue(false).done().toByteBuffer())
        assertEquals(false, reader.readValue())
        assert(!reader.hasMore())

        reader = ReaderWriterBuffer.reader(newWriter().writeValue(1).done().toByteBuffer())
        assertEquals(1, reader.readValue<Int>())
        assert(!reader.hasMore())

        reader = ReaderWriterBuffer.reader(newWriter().writeValue(12L).done().toByteBuffer())
        assertEquals(12L, reader.readValue()!!)
        assert(!reader.hasMore())

        reader =
            ReaderWriterBuffer.reader(newWriter().writeValue(1.0.toFloat()).done().toByteBuffer())
        assertEquals(1.0, reader.readValue()!!, 0.0)
        assert(!reader.hasMore())

        reader = ReaderWriterBuffer.reader(newWriter().writeValue(122.11).done().toByteBuffer())
        assertEquals(122.11, reader.readValue()!!, 0.0)
        assert(!reader.hasMore())

        val str = "មាន\u200Bរឿង\u200Bអ្វី\u200Bកើតឡើង? what's happen?"
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(str).done().toByteBuffer())
        assertEquals(str, reader.readValue())
        assert(!reader.hasMore())

        val ba = byteArrayOf(1, 2, 3, 4)
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(ba).done().toByteBuffer())
        assertArrayEquals(ba, reader.readValue())
        assert(!reader.hasMore())

        val ia = intArrayOf(11, 21, 32, 44)
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(ia).done().toByteBuffer())
        assertArrayEquals(ia, reader.readValue())
        assert(!reader.hasMore())

        val la = longArrayOf(121, 211, 302, 544)
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(la).done().toByteBuffer())
        assertArrayEquals(la, reader.readValue())
        assert(!reader.hasMore())

        val fa = floatArrayOf(1.31.toFloat(), 21.11.toFloat(), 3.022.toFloat(), 54.34.toFloat())
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(fa).done().toByteBuffer())
        assert(Arrays.equals(fa.toDoubleArray(), reader.readValue()))
        assert(!reader.hasMore())

        val da = doubleArrayOf(12.31, 32.11, 563.22, 564.384)
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(da).done().toByteBuffer())
        assert(Arrays.equals(da, reader.readValue()))
        assert(!reader.hasMore())

        val al = ArrayList(arrayListOf(1, "test", 1.0))
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(al).done().toByteBuffer())
        assertEquals(al, reader.readValue())
        assert(!reader.hasMore())

        val map = hashMapOf(1 to 1.0, "test" to 100, 1.0 to "value")
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(map).done().toByteBuffer())
        assertEquals(map, reader.readValue())
        assert(!reader.hasMore())

        val photo = PhotoApis.Photo.newBuilder()
            .setFileSize(100)
            .setHeight(1000)
            .setWidth(1200)
            .setName("DCMP-2019.JPEG")
            .setLocalIdentifier("5fad177c-0205-42d5-8964-8741b15f9a97")
            .build()
        reader = ReaderWriterBuffer.reader(newWriter().writeValue(photo).done().toByteBuffer())
        assertEquals(photo, reader.readValue { bytes -> PhotoApis.Photo.parseFrom(bytes) })
        assert(!reader.hasMore())
    }

    @Test
    fun testReadWriteMultiple() {
        val writer = ReaderWriterBuffer.writer()
        val b = 1
        writer.writeValue(b)
        val d = 20.43
        writer.writeValue(d)
        val a = intArrayOf(2, 88, 62)
        writer.writeValue(a)
        val l = ArrayList(arrayListOf(1, "Test", 11.0))
        writer.writeValue(l)
        val m = hashMapOf(1 to 1.0, "test" to 100, 1.0 to "value")
        writer.writeValue(m)
        val photo = PhotoApis.Photo.newBuilder()
            .setFileSize(100)
            .setHeight(1000)
            .setWidth(1200)
            .setName("DCMP-2019.JPEG")
            .setLocalIdentifier("5fad177c-0205-42d5-8964-8741b15f9a97")
            .build()
        writer.writeValue(photo)
        val reader = ReaderWriterBuffer.reader(writer.done().toByteBuffer())
        assertEquals(b, reader.readValue())
        assertEquals(d, reader.readValue()!!, 0.0)
        assertArrayEquals(a, reader.readValue())
        assertEquals(l, reader.readValue())
        assertEquals(m, reader.readValue())
        assertEquals(photo, reader.readValue { bytes -> PhotoApis.Photo.parseFrom(bytes) })
    }

}
