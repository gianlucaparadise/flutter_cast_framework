package com.gianlucaparadise.flutter_cast_framework.cast

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
import com.gianlucaparadise.flutter_cast_framework.FlutterCastFrameworkPlugin
import com.google.android.gms.cast.framework.CastContext

object CastDialogOpener {
    fun showCastDialog(applicationContext: Context, activity: Activity) {
        val castContext = CastContext.getSharedInstance(applicationContext)
        val castSession = castContext.sessionManager.currentCastSession

        val themeResId = activity.packageManager.getActivityInfo(activity.componentName, 0).themeResource

        try {
            if (castSession != null) {
                // This dialog allows the user to control or disconnect from the currently selected route.
                MediaRouteControllerDialog(activity, themeResId)
                        .show()
            } else if (castContext.mergedSelector != null) {
                // This dialog allows the user to choose a route that matches a given selector.
                MediaRouteChooserDialog(activity, themeResId).apply {
                    routeSelector = castContext.mergedSelector!!
                    show()
                }
            }
        } catch (ex: IllegalArgumentException) {
            Log.d(FlutterCastFrameworkPlugin.TAG, "Exception while opening Dialog")
            throw IllegalArgumentException("Error while opening MediaRouteDialog." +
                    " Did you use AppCompat theme on your activity?" +
                    " Check https://developers.google.com/cast/docs/android_sender/integrate#androidtheme", ex)
        }
    }
}