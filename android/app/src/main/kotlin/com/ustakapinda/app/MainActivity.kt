package com.ustakapinda.app

import android.os.Bundle
import android.util.Log
import com.tiktok.TikTokBusinessSdk
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        initializeTikTokMeasurement()
        super.onCreate(savedInstanceState)
    }

    private fun initializeTikTokMeasurement() {
        // Do not send identifiers, email, phone, location, messages, or profile data.
        if (TikTokBusinessSdk.isInitialized()) {
            return
        }

        runCatching {
            val config = TikTokBusinessSdk.TTConfig(application)
                .setAppId(BuildConfig.APPLICATION_ID)
                .setTTAppId(BuildConfig.TIKTOK_APP_ID)
                .disableAdvertiserIDCollection()
                .disableAutoEnhancedDataPostbackEvent()
                .disableAutoIapTrack()
                .disableMonitor()

            TikTokBusinessSdk.initializeSdk(config)
        }.onFailure {
            // Advertising measurement must never block or crash the app.
            Log.w("UstaKapinda", "TikTok measurement could not start", it)
        }
    }
}
