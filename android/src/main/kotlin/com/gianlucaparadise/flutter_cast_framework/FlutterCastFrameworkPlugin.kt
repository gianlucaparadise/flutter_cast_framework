package com.gianlucaparadise.flutter_cast_framework

import android.util.Log
import com.google.android.gms.cast.framework.CastContext
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterCastFrameworkPlugin(registrar: Registrar, private val channel: MethodChannel): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_cast_framework")
      channel.setMethodCallHandler(FlutterCastFrameworkPlugin(registrar, channel))
    }
  }

  init {
    CastContext.getSharedInstance(registrar.activeContext()).addCastStateListener { i ->
      Log.d("Android", "Method call on flutter: $i")
      channel.invokeMethod("onCastStateChanged", i)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }
}
