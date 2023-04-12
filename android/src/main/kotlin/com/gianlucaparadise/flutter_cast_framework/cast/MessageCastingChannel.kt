package com.gianlucaparadise.flutter_cast_framework.cast

import android.util.Log
import com.gianlucaparadise.flutter_cast_framework.PlatformBridgeApis
import com.google.android.gms.cast.Cast
import com.google.android.gms.cast.CastDevice
import com.google.android.gms.cast.framework.CastSession

class MessageCastingChannel(private val flutterApi : PlatformBridgeApis.CastFlutterApi) : Cast.MessageReceivedCallback {
    companion object {
        const val TAG = "MessageCastingChannel"
    }

    override fun onMessageReceived(castDevice: CastDevice, namespace: String, message: String) {
        Log.d(TAG, "Message received: $message:")
        val castMessage = PlatformBridgeApis.CastMessage()
        castMessage.namespace = namespace
        castMessage.message = message

        flutterApi.onMessageReceived(castMessage) {}
    }

    fun sendMessage(castSession: CastSession?, castMessage: PlatformBridgeApis.CastMessage?) {
        Log.d(TAG, "Send Message arguments: $castMessage:")
        if (castMessage == null) return

        if (castSession == null) {
            Log.d(TAG, "No session")
            return
        }

        val namespace = castMessage.namespace
        val message = castMessage.message

        if (namespace == null) {
            Log.d(TAG, "No namespace")
            return
        }

        if (message == null) {
            Log.d(TAG, "No message")
            return
        }

        sendMessage(castSession, namespace, message)
    }

    private fun sendMessage(castSession: CastSession, namespace: String, message: String) {
        try {
            castSession.sendMessage(namespace, message)
        } catch (ex: Exception) {
            Log.e(TAG, "Error while sending ${message}:")
            Log.e(TAG, ex.toString())
        }
    }

}