package br.com.threedaysapp.pomodoro

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import android.view.ViewTreeObserver
import android.view.WindowManager

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val flutter_native_splash = true

    GeneratedPluginRegistrant.registerWith(this)
    val vto = flutterView.viewTreeObserver
    vto.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
      }
    })

  }
}