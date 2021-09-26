package com.gianlucaparadise.flutter_cast_framework

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import com.gianlucaparadise.flutter_cast_framework.cast.CastDialogOpener
import com.gianlucaparadise.flutter_cast_framework.cast.MessageCastingChannel
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import com.google.android.gms.cast.framework.SessionManagerListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterCastFrameworkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleObserver {
    companion object {
        const val TAG = "AndroidCastPlugin"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterCastFrameworkPlugin()
            plugin.onAttachedToEngine(registrar.context(), registrar.messenger())
        }
    }

    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    //region FlutterPlugin interface
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        this.applicationContext = applicationContext

        val methodChannel = MethodChannel(messenger, "flutter_cast_framework")
        methodChannel.setMethodCallHandler(this)
        channel = methodChannel

        mMessageCastingChannel = MessageCastingChannel(methodChannel)

        CastContext.getSharedInstance(applicationContext).addCastStateListener { i ->
            Log.d(TAG, "Cast state changed: $i")
            methodChannel.invokeMethod(MethodNames.onCastStateChanged, i)
        }

        mSessionManager = CastContext.getSharedInstance(applicationContext).sessionManager
        mCastSession = mSessionManager.currentCastSession
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        applicationContext = null;
        channel?.setMethodCallHandler(null);
        channel = null;
        mMessageCastingChannel = null
    }
    //endregion

    //region ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        activity = null
    }
    //endregion

    private lateinit var mSessionManager: SessionManager
    private val mSessionManagerListener = CastSessionManagerListener()

    private var channel: MethodChannel? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    private var mMessageCastingChannel: MessageCastingChannel? = null

    private var mCastSession: CastSession? = null
        set(value) {
            Log.d(TAG, "Updating mCastSession - castSession changed: ${field != value}")
            // if (field == value) return // Despite the instances are the same, I need to re-attach the listener to every new session instance

            val result = NamespaceResult(oldSession = field, newSession = value)

            field = value

            channel?.invokeMethod(MethodNames.getSessionMessageNamespaces, null, result)
        }

    //region LifecycleObserver
    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    fun onCreate() {
        Log.d(TAG, "App: ON_CREATE")
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        Log.d(TAG, "App: ON_RESUME")
        mSessionManager.addSessionManagerListener(mSessionManagerListener, CastSession::class.java)
        mCastSession = mSessionManager.currentCastSession

        val context = applicationContext
        if (context == null) {
            Log.d(TAG, "App: ON_RESUME - missing context")
            return
        }
        val castState = CastContext.getSharedInstance(context).castState
        channel?.invokeMethod(MethodNames.onCastStateChanged, castState)
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onPause() {
        Log.d(TAG, "App: ON_PAUSE")
        mSessionManager.removeSessionManagerListener(
                mSessionManagerListener,
                CastSession::class.java
        )
        // I can't set this to null because I need the cast session to send commands from notification
        // mCastSession = null
    }
    //endregion

    override fun onMethodCall(call: MethodCall, result: Result) {
        val method = call.method
        val arguments = call.arguments

        when (method) {
            MethodNames.showCastDialog -> {
                val context = applicationContext
                val activity = this.activity
                if (context == null || activity == null) {
                    Log.d(TAG, "onMethodCall - missing context")
                    return
                }

                CastDialogOpener.showCastDialog(context, activity)
            }
            MethodNames.sendMessage -> this.mMessageCastingChannel?.sendMessage(mCastSession, arguments)
            else -> result.notImplemented()
        }
    }

    private inner class NamespaceResult(val oldSession: CastSession?, val newSession: CastSession?) : Result {
        override fun notImplemented() {
            Log.d(TAG, "Updating mCastSession - notImplemented")
        }

        override fun error(p0: String?, p1: String?, p2: Any?) {
            Log.d(TAG, "Updating mCastSession - error - $p0 $p1 $p2")
        }

        override fun success(args: Any?) {
            Log.d(TAG, "Updating mCastSession - success - param: $args")
            if (oldSession == null && newSession == null) return // nothing to do here
            if (args == null) return // nothing to do here

            if (args !is ArrayList<*>)
                throw IllegalArgumentException("${MethodNames.getSessionMessageNamespaces} method expects an ArrayList<String>")

            if (!args.any()) return  // nothing to do here

            if (args[0] !is String)
                throw IllegalArgumentException("${MethodNames.getSessionMessageNamespaces} method expects an ArrayList<String>")

            val namespaces = args as ArrayList<String>
            namespaces.forEach {
                try {
                    oldSession?.removeMessageReceivedCallbacks(it)
                    newSession?.setMessageReceivedCallbacks(it, mMessageCastingChannel)
                } catch (e: java.lang.Exception) {
                    Log.e(TAG, "Updating mCastSession - Exception while creating channel", e)
                }
            }
        }
    }

    private inner class CastSessionManagerListener : SessionManagerListener<CastSession> {
        private var TAG = "SessionManagerListenerImpl"

        override fun onSessionSuspended(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionSuspended - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionSuspended, null)
        }

        override fun onSessionStarting(session: CastSession?) {
            Log.d(TAG, "onSessionStarting - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionStarting, null)

            mCastSession = session
        }

        override fun onSessionResuming(session: CastSession?, p1: String?) {
            Log.d(TAG, "onSessionResuming - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionResuming, null)

            mCastSession = session
        }

        override fun onSessionEnding(session: CastSession?) {
            Log.d(TAG, "onSessionEnding - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionEnding, null)
        }

        override fun onSessionStartFailed(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionStartFailed - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionStartFailed, null)
        }

        override fun onSessionResumeFailed(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionResumeFailed - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionResumeFailed, null)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            Log.d(TAG, "onSessionStarted - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionStarted, null)

            mCastSession = session
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            Log.d(TAG, "onSessionResumed - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionResumed, null)

            mCastSession = session
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            Log.d(TAG, "onSessionEnded - channel is null? ${channel == null}")
            channel?.invokeMethod(MethodNames.onSessionEnded, null)
        }
    }
}
