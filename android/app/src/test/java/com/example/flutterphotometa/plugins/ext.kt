package com.example.flutterphotometa.plugins

import android.annotation.SuppressLint
import com.google.protobuf.MessageLite
import org.jetbrains.annotations.TestOnly
import java.nio.ByteBuffer

/*** Helper to testing purpose ***/

@TestOnly
fun List<*>.byteCount(): Int {
    var count = 0
    this.forEach {
        count += countBytes(it)
    }
    return count
}

@SuppressLint("NewApi")
@TestOnly
fun Map<*,*>.byteCount(): Int {
    var count = 0
    this.forEach { (k, v) ->
        count += countBytes(k)
        count += countBytes(v)
    }
    return count
}

@TestOnly
fun countBytes(it: Any?): Int {
    return when(it){
        is Boolean -> { 1 + 1 }
        is Int -> { 1 + 4 }
        // Float written to buffer as double 8 bytes to make it compatible with dart
        is Long, is Double, is Float -> { 1 + 8 }
        is ByteArray -> { 1 + 4 + it.size }
        is IntArray -> { 1 + 4 + (it.size * 4) }
        is LongArray -> { 1 + 4 + (it.size * 8) }
        is FloatArray -> { 1 + 4 + (it.size * 8) }
        is DoubleArray -> { 1 + 4 + (it.size * 8) }
        is String -> { 1 + 4 + it.toByteArray().size }
        is List<*> -> { 1 + 4 + it.byteCount() }
        is Map<*, *> -> { 1 + 4 + it.byteCount()  }
        is MessageLite -> { 1 + 4 + it.toByteArray().size }
        else -> { 0 }
    }
}

@TestOnly
fun FloatArray.toDoubleArray(): DoubleArray {
    val da = DoubleArray(this.size)
    this.forEachIndexed { index, fl -> da[index] = fl.toDouble() }
    return da
}

@TestOnly
fun ByteArray.toByteBuffer(): ByteBuffer {
    return ByteBuffer.wrap(this)
}