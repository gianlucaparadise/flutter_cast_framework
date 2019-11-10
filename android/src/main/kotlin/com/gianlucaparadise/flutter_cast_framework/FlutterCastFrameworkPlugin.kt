package com.gianlucaparadise.flutter_cast_framework

import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
import com.google.android.gms.cast.framework.CastContext
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
            channel.invokeMethod("onCastStateChanged", i)
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        Log.d(TAG, "App: ON_RESUME")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showCastDialog" -> showCastDialog()
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
}
