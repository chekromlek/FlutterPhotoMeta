package com.example.flutterphotometa.plugins

import com.example.flutterphotometa.extensions.*
import com.example.flutterphotometa.protobuf.FlutterPlugins
import com.google.protobuf.MessageLite
import java.nio.ByteBuffer

/**
 * Writer to encode data type into binary
 */
interface BufferWriter {
    /**
     * Write a binary value to the buffer
     */
    fun writeByte(b: Byte): BufferWriter

    /**
     * Write a byte array value to the buffer
     */
    fun writeBytes(bs: ByteArray): BufferWriter

    /**
     * Write the entire byte array of ByteBuffer data if position of ByteBuffer is 0 and limit is equal
     * to capacity of the buffer otherwise it write the byte from 0 position until current position
     */
    fun writeByteBuffer(bb: ByteBuffer): BufferWriter

    /**
     * Write String value into binary buffer
     */
    fun writeUTF8(s: String): BufferWriter

    /**
     * Write any value that capable to encode into binary. It support any primitive type including
     * List, Map and Protobuf Message
     */
    fun <T : Any> writeValue(v: T?): BufferWriter

    /**
     * Write size of binary encoded data
     */
    fun writeSize(size: Int): BufferWriter

    /**
     * Return the final computed byte array. After calling done, the buffer can no longer accept any
     * write request and a null pointer except it raised
     */
    fun done(): ByteArray

    /**
     * Return the final computed byte array as byte buffer
     */
    fun seal(): ByteBuffer
}

/**
 * Reader to decode and read value from the binary data
 */
interface BufferReader {
    /**
     * Check whether the reader still have any data less
     */
    fun hasMore(): Boolean

    /**
     * Read a byte from the buffer
     */
    fun readByte(): Byte

    /**
     * Read a byte array from the buffer
     */
    fun readBytes(): ByteArray

    /**
     * Read a string utf8 from the buffer
     */
    fun readUTF8(): String

    /**
     * Read any value from the buffer
     */
    fun <T> readValue(creator: ProtoMessageCreator<T>? = { null }): T?

    /**
     * Read size of encoded data
     */
    fun readSize(): Int
}

/**
 *
 */
typealias TypeWriter<T> = (writer: ReaderWriterBuffer, value: T) -> Unit

/**
 *
 */
typealias TypeReader = (reader: ReaderWriterBuffer) -> Any?


/**
 *
 */
typealias ProtoMessageCreator<T> = (bytes: ByteArray) -> T?

/**
 *
 */
class ReaderWriterBuffer private constructor(var buffer: ByteArray?) : BufferWriter, BufferReader {

    companion object Factory {

        private const val messageKey = "proto-message-key"

        /**
         *
         */
        fun writer(): BufferWriter = ReaderWriterBuffer(ByteArray(0))

        /**
         *
         */
        fun reader(buffer: ByteBuffer): BufferReader = ReaderWriterBuffer(buffer.array())

        /*** type writer mapping ***/
        val typeWriter: Map<String, TypeWriter<Any>> = mapOf(
            (true as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.BOOL.number.toByte())
                writer.writeByte((value as Boolean).toByte())
            },
            (1 as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.INT32.number.toByte())
                writer.buffer = writer.buffer?.plus((value as Int).toBytes())
            },
            (1L as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.INT64.number.toByte())
                writer.buffer = writer.buffer?.plus((value as Long).toBytes())
            },
            (1.0.toFloat() as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.FLOAT64.number.toByte())
                writer.buffer = writer.buffer?.plus((value as Float).toDouble().toBytes())
            },
            (1.0 as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.FLOAT64.number.toByte())
                writer.buffer = writer.buffer?.plus((value as Double).toBytes())
            },
            ("" as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.STRING.number.toByte())
                writer.writeBytes((value as String).toByteArray())
            },
            (ByteArray(0) as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.UINT8LIST.number.toByte())
                writer.writeSize((value as ByteArray).size)
                writer.buffer = writer.buffer?.plus(value)
            },
            (IntArray(0) as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.INT32LIST.number.toByte())
                writer.writeSize((value as IntArray).size)
                writer.buffer = writer.buffer?.plus(value.toBytes())
            },
            (LongArray(0) as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.INT64LIST.number.toByte())
                writer.writeSize((value as LongArray).size)
                writer.buffer = writer.buffer?.plus(value.toBytes())
            },
            (FloatArray(0) as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                // allow compatible with dart and swift
                writer.writeByte(FlutterPlugins.DataType.FLOAT64LIST.number.toByte())
                writer.writeSize((value as FloatArray).size)
                writer.buffer = writer.buffer?.plus(value.toBytes())
            },
            (DoubleArray(0) as Any).javaClass.name to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.FLOAT64LIST.number.toByte())
                writer.writeSize((value as DoubleArray).size)
                writer.buffer = writer.buffer?.plus(value.toBytes())
            },
            (ArrayList<Any>() as Any).javaClass.name to fun(
                writer: ReaderWriterBuffer,
                value: Any
            ) {
                writer.writeByte(FlutterPlugins.DataType.LIST.number.toByte())
                @Suppress("UNCHECKED_CAST")
                val list = value as List<Any>
                writer.writeSize(list.size)
                list.forEach { writer.writeValue(it) }
            },
            (HashMap<Any, Any>() as Any).javaClass.name to fun(
                writer: ReaderWriterBuffer,
                value: Any
            ) {
                writer.writeByte(FlutterPlugins.DataType.MAP.number.toByte())
                @Suppress("UNCHECKED_CAST")
                val map = value as Map<Any, Any>
                writer.writeSize(map.size)
                for ((k, v) in map) {
                    writer.writeValue(k)
                    writer.writeValue(v)
                }
            },
            messageKey to fun(writer: ReaderWriterBuffer, value: Any) {
                writer.writeByte(FlutterPlugins.DataType.MESSAGE.number.toByte())
                writer.writeBytes((value as MessageLite).toByteArray())
            }
        )

        /*** type reader mapping ***/
        private val typeReader: Map<FlutterPlugins.DataType, TypeReader> = mapOf(
            FlutterPlugins.DataType.NULL to fun(_: ReaderWriterBuffer): Any? {
                return null
            },
            FlutterPlugins.DataType.BOOL to fun(reader: ReaderWriterBuffer): Any? {
                try {
                    return reader.readByte() == 1.toByte()
                } finally {
                    reader.pos += 1
                }
            },
            FlutterPlugins.DataType.INT32 to fun(reader: ReaderWriterBuffer): Any? {
                try {
                    return reader.buffer!!.toInt(reader.pos)
                } finally {
                    reader.pos += 4
                }
            },
            FlutterPlugins.DataType.INT64 to fun(reader: ReaderWriterBuffer): Any? {
                try {
                    return reader.buffer!!.toLong(reader.pos)
                } finally {
                    reader.pos += 8
                }
            },
            FlutterPlugins.DataType.FLOAT64 to fun(reader: ReaderWriterBuffer): Any? {
                try {
                    return reader.buffer!!.toDouble(reader.pos)
                } finally {
                    reader.pos += 8
                }
            },
            FlutterPlugins.DataType.STRING to fun(reader: ReaderWriterBuffer): Any? {
                return reader.readUTF8()
            },
            FlutterPlugins.DataType.UINT8LIST to fun(reader: ReaderWriterBuffer): Any? {
                return reader.readBytes()
            },
            FlutterPlugins.DataType.INT32LIST to fun(reader: ReaderWriterBuffer): Any? {
                val size = reader.readSize()
                try {
                    val ia = IntArray(size)
                    for (i in 0 until size) {
                        ia[i] = reader.buffer!!.toInt(reader.pos + (i * 4))
                    }
                    return ia
                } finally {
                    reader.pos += size * 4
                }
            },
            FlutterPlugins.DataType.INT64LIST to fun(reader: ReaderWriterBuffer): Any? {
                val size = reader.readSize()
                try {
                    val la = LongArray(size)
                    for (i in 0 until size) {
                        la[i] = reader.buffer!!.toLong(reader.pos + (i * 8))
                    }
                    return la
                } finally {
                    reader.pos += size * 8
                }
            },
            FlutterPlugins.DataType.FLOAT64LIST to fun(reader: ReaderWriterBuffer): Any? {
                val size = reader.readSize()
                try {
                    val da = DoubleArray(size)
                    for (i in 0 until size) {
                        da[i] = reader.buffer!!.toDouble(reader.pos + (i * 8))
                    }
                    return da
                } finally {
                    reader.pos += size * 8
                }
            },
            FlutterPlugins.DataType.LIST to fun(reader: ReaderWriterBuffer): Any? {
                val size = reader.readSize()
                val da = ArrayList<Any?>()
                for (i in 0 until size) {
                    val aValue: Any? = reader.readValue()
                    da.add(aValue)
                }
                return da
            },
            FlutterPlugins.DataType.MAP to fun(reader: ReaderWriterBuffer): Any? {
                val size = reader.readSize()
                val ma = HashMap<Any, Any?>()
                for (i in 0 until size) {
                    val aKey: Any? = reader.readValue()
                    (aKey)?.let { ma.put(it, reader.readValue()) }
                }
                return ma
            },
            FlutterPlugins.DataType.MESSAGE to fun(reader: ReaderWriterBuffer): Any? {
                return reader.readBytes()
            }
        )

    }

    // position of byte array
    private var pos: Int = 0

    /*** Writer Implementation ***/

    override fun writeByte(b: Byte): BufferWriter {
        this.buffer = this.buffer?.plus(b)
        return this
    }

    override fun writeBytes(bs: ByteArray): BufferWriter {
        this.writeSize(bs.size)
        this.buffer = this.buffer?.plus(bs)
        return this
    }

    override fun writeByteBuffer(bb: ByteBuffer): BufferWriter {
        if (bb.position() != 0) {
            this.writeSize(bb.position())
            this.buffer = this.buffer?.plus(bb.array().sliceArray(0..bb.position()))
        } else {
            this.writeSize(bb.capacity())
            this.buffer = this.buffer?.plus(bb.array())
        }
        return this
    }

    override fun writeUTF8(s: String): BufferWriter {
        val byteArray = s.toByteArray()
        this.writeSize(byteArray.size)
        this.buffer = this.buffer?.plus(byteArray)
        return this
    }

    override fun <T : Any> writeValue(v: T?): BufferWriter {
        if (v == null) {
            this.writeByte(FlutterPlugins.DataType.NULL_VALUE.toByte())
        } else {
            when (v) {
                is MessageLite -> {
                    (typeWriter[messageKey] ?: error("")).invoke(
                        this,
                        v as @ParameterName(name = "value") Any
                    )
                }
                else -> {
                    (typeWriter[v!!.javaClass.name] ?: error("")).invoke(
                        this,
                        v as @ParameterName(name = "value") Any
                    )
                }
            }
        }
        return this
    }

    override fun writeSize(size: Int): BufferWriter {
        this.buffer = this.buffer?.plus(size.toBytes())
        return this
    }

    override fun done(): ByteArray {
        try {
            if (this.buffer == null) throw RuntimeException("Invalid buffer")
            return this.buffer!!
        } finally {
            this.buffer = null
        }
    }

    override fun seal(): ByteBuffer {
        val bytes = done()
        val buffer = ByteBuffer.allocateDirect(bytes.size)
        buffer.put(bytes, 0, bytes.size)
        return buffer
    }

    /*** Reader Implementation ***/

    override fun hasMore(): Boolean {
        return buffer!!.size > this.pos
    }

    override fun readByte(): Byte {
        try {
            return this.buffer!![pos]
        } finally {
            this.pos += 1
        }
    }

    override fun readBytes(): ByteArray {
        val size = readSize()
        try {
            return this.buffer!!.sliceArray(pos until pos + size)
        } finally {
            this.pos += size
        }
    }

    override fun readUTF8(): String {
        val size = readSize()
        try {
            return String(this.buffer!!, pos, size)
        } finally {
            this.pos += size
        }
    }

    override fun <T> readValue(creator: ProtoMessageCreator<T>?): T? {
        val kind = FlutterPlugins.DataType.forNumber(readByte().toInt())
        return typeReader[kind]?.let {
            val result = it(this)
            when (kind) {
                FlutterPlugins.DataType.MESSAGE -> {
                    return creator?.let { it(result as @ParameterName(name = "bytes") ByteArray) }
                }
                else -> {
                    @Suppress("UNCHECKED_CAST")
                    return result?.let { it as? T }
                }
            }
        }
    }

    override fun readSize(): Int {
        try {
            return this.buffer!!.toInt(this.pos)
        } finally {
            this.pos += 4
        }
    }

}