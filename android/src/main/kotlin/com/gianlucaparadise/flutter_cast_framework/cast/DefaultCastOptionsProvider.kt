package com.gianlucaparadise.flutter_cast_framework.cast

import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider


/**
 * This is here to be used as an example
 */
class DefaultCastOptionsProvider : OptionsProvider {
    // TODO: find a way to build this from dart code. Maybe source_gen?

    override fun getCastOptions(context: Context): CastOptions {
        return CastOptions.Builder()
                .setReceiverApplicationId("4F8B3483")
                .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? {
        return null
    }
}