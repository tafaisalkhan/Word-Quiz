package com.example.word_quiz

import android.media.Ringtone
import android.media.RingtoneManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val feedbackChannel = "word_quiz/feedback_tones"
    private val correctAnswerTone = "play_correct_answer_tone"
    private val wrongAnswerTone = "play_wrong_answer_tone"
    private val completeTone = "play_complete_tone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            feedbackChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                correctAnswerTone -> {
                    playTone(RingtoneManager.TYPE_NOTIFICATION)
                    result.success(null)
                }
                wrongAnswerTone -> {
                    playTone(RingtoneManager.TYPE_NOTIFICATION)
                    result.success(null)
                }
                completeTone -> {
                    playTone(RingtoneManager.TYPE_NOTIFICATION)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playTone(ringtoneType: Int) {
        val uri = RingtoneManager.getDefaultUri(ringtoneType) ?: return
        playUri(uri)
    }

    private fun playUri(uri: android.net.Uri) {
        val ringtone: Ringtone = RingtoneManager.getRingtone(applicationContext, uri) ?: return
        ringtone.play()
    }
}
