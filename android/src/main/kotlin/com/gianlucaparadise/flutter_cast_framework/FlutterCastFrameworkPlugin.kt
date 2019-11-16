package com.gianlucaparadise.flutter_cast_framework

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
import com.gianlucaparadise.flutter_cast_framework.cast.CastDialogOpener
import com.gianlucaparadise.flutter_cast_framework.cast.MessageCastingChannel
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import com.google.android.gms.cast.framework.SessionManagerListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterCastFrameworkPlugin(private val registrar: Registrar, private val channel: MethodChannel) : MethodCallHandler, LifecycleObserver {
    companion object {
        const val TAG = "AndroidCastPlugin"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_cast_framework")
            channel.setMethodCallHandler(FlutterCastFrameworkPlugin(registrar, channel))
        }
    }

    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)

        CastContext.getSharedInstance(registrar.activeContext()).addCastStateListener { i ->
            Log.d(TAG, "Cast state changed: $i")
            channel.invokeMethod(MethodNames.onCastStateChanged, i)
        }
    }

    private lateinit var mSessionManager: SessionManager
    private val mSessionManagerListener = CastSessionManagerListener()

    private val mMessageCastingChannel = MessageCastingChannel(channel)

    private var mCastSession: CastSession? = null
        set(value) {
            Log.d(TAG, "Updating mCastSession - castSession changed: ${field != value}")
            // if (field == value) return // Despite the instances are the same, I need to re-attach the listener to every new session instance

            val result = NamespaceResult(oldSession = field, newSession = value)

            field = value

            channel.invokeMethod(MethodNames.getSessionMessageNamespaces, null, result)
        }

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    fun onCreate() {
        Log.d(TAG, "App: ON_CREATE")
        mSessionManager = CastContext.getSharedInstance(registrar.activeContext()).sessionManager
        mCastSession = mSessionManager.currentCastSession
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        Log.d(TAG, "App: ON_RESUME")
        mSessionManager.addSessionManagerListener(mSessionManagerListener, CastSession::class.java)
        mCastSession = mSessionManager.currentCastSession

        val castState = CastContext.getSharedInstance(registrar.activeContext()).castState
        channel.invokeMethod(MethodNames.onCastStateChanged, castState)
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

    override fun onMethodCall(call: MethodCall, result: Result) {
        val method = call.method
        val arguments = call.arguments

        when (method) {
            MethodNames.showCastDialog -> CastDialogOpener.showCastDialog(registrar)
            MethodNames.sendMessage -> this.mMessageCastingChannel.sendMessage(mCastSession, arguments)
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
                }
                catch (e: java.lang.Exception) {
                    Log.e(TAG, "Updating mCastSession - Exception while creating channel", e)
                }
            }
        }
    }

    private inner class CastSessionManagerListener : SessionManagerListener<CastSession> {
        private var TAG = "SessionManagerListenerImpl"

        override fun onSessionSuspended(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionSuspended")
            channel.invokeMethod(MethodNames.onSessionSuspended, null)
        }

        override fun onSessionStarting(session: CastSession?) {
            Log.d(TAG, "onSessionStarting")
            channel.invokeMethod(MethodNames.onSessionStarting, null)

            mCastSession = session
        }

        override fun onSessionResuming(session: CastSession?, p1: String?) {
            Log.d(TAG, "onSessionResuming")
            channel.invokeMethod(MethodNames.onSessionResuming, null)

            mCastSession = session
        }

        override fun onSessionEnding(session: CastSession?) {
            Log.d(TAG, "onSessionEnding")
            channel.invokeMethod(MethodNames.onSessionEnding, null)
        }

        override fun onSessionStartFailed(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionStartFailed")
            channel.invokeMethod(MethodNames.onSessionStartFailed, null)
        }

        override fun onSessionResumeFailed(session: CastSession?, p1: Int) {
            Log.d(TAG, "onSessionResumeFailed")
            channel.invokeMethod(MethodNames.onSessionResumeFailed, null)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            Log.d(TAG, "onSessionStarted")
            channel.invokeMethod(MethodNames.onSessionStarted, null)

            mCastSession = session
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            Log.d(TAG, "onSessionResumed")
            channel.invokeMethod(MethodNames.onSessionResumed, null)

            mCastSession = session
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            Log.d(TAG, "onSessionEnded")
            channel.invokeMethod(MethodNames.onSessionEnded, null)
        }
    }
}
