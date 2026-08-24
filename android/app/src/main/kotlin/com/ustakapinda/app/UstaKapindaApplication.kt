package com.ustakapinda.app

import android.app.Application
import android.util.Log
import com.tiktok.TikTokBusinessSdk

class UstaKapindaApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Register lifecycle tracking before the first Activity opens. No user,
        // contact, message, location, or advertising-ID data is provided here.
        if (TikTokBusinessSdk.isInitialized()) return

        runCatching {
            val config = TikTokBusinessSdk.TTConfig(this)
                .setAppId(BuildConfig.APPLICATION_ID)
                .setTTAppId(BuildConfig.TIKTOK_APP_ID)
                .disableAdvertiserIDCollection()
                .disableAutoEnhancedDataPostbackEvent()
                .disableAutoIapTrack()
                .disableMonitor()

            TikTokBusinessSdk.initializeSdk(config)
        }.onFailure {
            // Measurement must never prevent the application from opening.
            Log.w("UstaKapinda", "TikTok measurement could not start", it)
        }
    }
}
