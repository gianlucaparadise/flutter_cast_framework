package com.gianlucaparadise.flutter_cast_framework.cast

import android.util.Log
import com.gianlucaparadise.flutter_cast_framework.HostApis
import com.gianlucaparadise.flutter_cast_framework.MethodNames
import com.google.android.gms.cast.Cast
import com.google.android.gms.cast.CastDevice
import com.google.android.gms.cast.framework.CastSession
import io.flutter.plugin.common.MethodChannel

class MessageCastingChannel(private val channel: MethodChannel) : Cast.MessageReceivedCallback {
    companion object {
        const val TAG = "MessageCastingChannel"
    }

    override fun onMessageReceived(castDevice: CastDevice?, namespace: String?, message: String?) {
        Log.d(TAG, "Message received: $message:")
        val argsMap: HashMap<String, String?> = hashMapOf(
                "namespace" to namespace,
                "message" to message
        )

        channel.invokeMethod(MethodNames.onMessageReceived, argsMap)
    }

    fun sendMessage(castSession: CastSession?, castMessage: HostApis.CastMessage?) {
        Log.d(TAG, "Send Message arguments: $castMessage:")
        if (castMessage == null) return

        val namespace = castMessage.namespace
        val message = castMessage.message

        sendMessage(castSession, namespace, message)
    }

    private fun sendMessage(castSession: CastSession?, namespace: String?, message: String?) {
        try {
            if (castSession == null) {
                Log.d(TAG, "No session")
                return
            }

            castSession.sendMessage(namespace, message)

        } catch (ex: Exception) {
            Log.e(TAG, "Error while sending ${message}:")
            Log.e(TAG, ex.toString())
        }
    }

}