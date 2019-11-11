package com.gianlucaparadise.flutter_cast_framework

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
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

    private object MethodNames {
        const val onCastStateChanged = "CastContext.onCastStateChanged"
        const val showCastDialog = "showCastDialog"

        // region SessionManager
        const val onSessionStarting = "SessionManager.onSessionStarting"
        const val onSessionStarted = "SessionManager.onSessionStarted"
        const val onSessionStartFailed = "SessionManager.onSessionStartFailed"
        const val onSessionEnding = "SessionManager.onSessionEnding"
        const val onSessionEnded = "SessionManager.onSessionEnded"
        const val onSessionResuming = "SessionManager.onSessionResuming"
        const val onSessionResumed = "SessionManager.onSessionResumed"
        const val onSessionResumeFailed = "SessionManager.onSessionResumeFailed"
        const val onSessionSuspended = "SessionManager.onSessionSuspended"
        // end-region
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

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    fun onCreate() {
        Log.d(TAG, "App: ON_CREATE")
        mSessionManager = CastContext.getSharedInstance(registrar.activeContext()).sessionManager
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        Log.d(TAG, "App: ON_RESUME")
        mSessionManager.addSessionManagerListener(mSessionManagerListener, CastSession::class.java)
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onPause() {
        Log.d(TAG, "App: ON_PAUSE")
        mSessionManager.removeSessionManagerListener(
                mSessionManagerListener,
                CastSession::class.java
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodNames.showCastDialog -> showCastDialog()
            else -> result.notImplemented()
        }
    }

    private fun showCastDialog() {
        val castContext = CastContext.getSharedInstance(registrar.activeContext())
        val castSession = castContext.sessionManager.currentCastSession

        val activity = this.registrar.activity()
        val themeResId = activity.packageManager.getActivityInfo(activity.componentName, 0).themeResource

        try {
            if (castSession != null) {
                // This dialog allows the user to control or disconnect from the currently selected route.
                MediaRouteControllerDialog(registrar.activeContext(), themeResId)
                        .show()
            } else {
                // This dialog allows the user to choose a route that matches a given selector.
                MediaRouteChooserDialog(registrar.activeContext(), themeResId).apply {
                    routeSelector = castContext.mergedSelector
                    show()
                }
            }
        } catch (ex: IllegalArgumentException) {
            Log.d(TAG, "Exception while opening Dialog")
            throw IllegalArgumentException("Error while opening MediaRouteDialog." +
                    " Did you use AppCompat theme on your activity?" +
                    " Check https://developers.google.com/cast/docs/android_sender/integrate#androidtheme", ex)
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
        }

        override fun onSessionResuming(session: CastSession?, p1: String?) {
            Log.d(TAG, "onSessionResuming")
            channel.invokeMethod(MethodNames.onSessionResuming, null)
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
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            Log.d(TAG, "onSessionResumed")
            channel.invokeMethod(MethodNames.onSessionResumed, null)
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            Log.d(TAG, "onSessionEnded")
            channel.invokeMethod(MethodNames.onSessionEnded, null)
        }
    }
}
