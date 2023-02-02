package com.gianlucaparadise.flutter_cast_framework.cast

import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider
import com.google.android.gms.cast.CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID

/**
 * This is here to be used as an example
 */
class DefaultCastOptionsProvider : OptionsProvider {
    // TODO: find a way to build this from dart code. Maybe source_gen?

    override fun getCastOptions(context: Context): CastOptions {
        return CastOptions.Builder()
                .setReceiverApplicationId(DEFAULT_MEDIA_RECEIVER_APPLICATION_ID)
                .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? {
        return null
    }
}