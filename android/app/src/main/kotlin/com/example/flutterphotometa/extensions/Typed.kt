package com.example.flutterphotometa.extensions

import java.nio.ByteBuffer

fun Int.toBytes(): ByteArray {
    val bytes = ByteArray(4)
    bytes[0] = this.toByte()
    bytes[1] = (this shr 8).toByte()
    bytes[2] = (this shr 16).toByte()
    bytes[3] = (this shr 24).toByte()
    return bytes
}

fun Long.toBytes(): ByteArray {
    val bytes = ByteArray(8)
    bytes[0] = this.toByte()
    bytes[1] = (this shr 8).toByte()
    bytes[2] = (this shr 16).toByte()
    bytes[3] = (this shr 24).toByte()
    bytes[4] = (this shr 32).toByte()
    bytes[5] = (this shr 40).toByte()
    bytes[6] = (this shr 48).toByte()
    bytes[7] = (this shr 56).toByte()
    return bytes
}

fun Boolean.toByte(): Byte {
    return if (this) 1 else 0
}

fun Double.toBytes(): ByteArray {
    val bytes = ByteArray(8)
    val long = this.toRawBits()
    bytes[0] = long.toByte()
    bytes[1] = (long shr 8).toByte()
    bytes[2] = (long shr 16).toByte()
    bytes[3] = (long shr 24).toByte()
    bytes[4] = (long shr 32).toByte()
    bytes[5] = (long shr 40).toByte()
    bytes[6] = (long shr 48).toByte()
    bytes[7] = (long shr 56).toByte()
    return bytes
}

fun Float.toBytes(): ByteArray {
    val bytes = ByteArray(4)
    val i = this.toRawBits()
    bytes[0] = i.toByte()
    bytes[1] = (i shr 8).toByte()
    bytes[2] = (i shr 16).toByte()
    bytes[3] = (i shr 24).toByte()
    return bytes
}

fun IntArray.toBytes(): ByteArray {
    return this.foldIndexed(ByteArray(this.size * 4)) { i, a, v ->
        a.apply {
            set((i * 4), v.toByte())
            set((i * 4) + 1, (v shr 8).toByte())
            set((i * 4) + 2, (v shr 16).toByte())
            set((i * 4) + 3, (v shr 24).toByte())
        }
    }
}

fun LongArray.toBytes(): ByteArray {
    return this.foldIndexed(ByteArray(this.size * 8)) { i, a, v ->
        a.apply {
            set((i * 8), v.toByte())
            set((i * 8) + 1, (v shr 8).toByte())
            set((i * 8) + 2, (v shr 16).toByte())
            set((i * 8) + 3, (v shr 24).toByte())
            set((i * 8) + 4, (v shr 32).toByte())
            set((i * 8) + 5, (v shr 40).toByte())
            set((i * 8) + 6, (v shr 48).toByte())
            set((i * 8) + 7, (v shr 56).toByte())
        }
    }
}

fun DoubleArray.toBytes(): ByteArray {
    return this.foldIndexed(ByteArray(this.size * 8)) { i, a, v ->
        a.apply {
            val longBit = v.toRawBits()
            set((i * 8), longBit.toByte())
            set((i * 8) + 1, (longBit shr 8).toByte())
            set((i * 8) + 2, (longBit shr 16).toByte())
            set((i * 8) + 3, (longBit shr 24).toByte())
            set((i * 8) + 4, (longBit shr 32).toByte())
            set((i * 8) + 5, (longBit shr 40).toByte())
            set((i * 8) + 6, (longBit shr 48).toByte())
            set((i * 8) + 7, (longBit shr 56).toByte())
        }
    }
}

fun FloatArray.toBytes(): ByteArray {
    return this.foldIndexed(ByteArray(this.size * 8)) { i, a, v ->
        a.apply {
            val longBit = v.toDouble().toRawBits()
            set((i * 8), longBit.toByte())
            set((i * 8) + 1, (longBit shr 8).toByte())
            set((i * 8) + 2, (longBit shr 16).toByte())
            set((i * 8) + 3, (longBit shr 24).toByte())
            set((i * 8) + 4, (longBit shr 32).toByte())
            set((i * 8) + 5, (longBit shr 40).toByte())
            set((i * 8) + 6, (longBit shr 48).toByte())
            set((i * 8) + 7, (longBit shr 56).toByte())
        }
    }
}

fun ByteArray.toInt(pos: Int = 0): Int {
    if ((pos == 0 && this.size < 4 || pos + 3 >= this.size )) throw RuntimeException("Invalid byte buffer")
    return (this[pos].toInt() and 0xff) or
            ((this[pos + 1].toInt() and 0xff) shl 8) or
            ((this[pos + 2].toInt() and 0xff) shl 16) or
            (this[pos + 3].toInt() shl 24)
}

fun ByteArray.toLong(pos: Int = 0): Long {
    if ((pos == 0 && this.size < 8) || pos + 3 >= this.size) throw RuntimeException("Invalid byte buffer")
    return (this[pos].toLong() and 0xff) or
            ((this[pos + 1].toLong() and 0xff) shl 8) or
            ((this[pos + 2].toLong() and 0xff) shl 16) or
            ((this[pos + 3].toLong() and 0xff) shl 24) or
            ((this[pos + 4].toLong() and 0xff) shl 32) or
            ((this[pos + 5].toLong() and 0xff) shl 40) or
            ((this[pos + 6].toLong() and 0xff) shl 48) or
            (this[pos + 7].toLong() shl 56)
}

fun ByteArray.toDouble(pos: Int = 0): Double {
    return Double.fromBits(this.toLong(pos))
}