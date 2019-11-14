# Flutter Cast Framework

## Overview

Flutter Cast Framework is a POC of a flutter plugin that lets you use Chromecast API in a flutter app.

## Exposed APIs

Currently only the following APIs are integrated:

* Android:
    * Cast State
    * Session state
    * Send custom message
    * Listen to received custom messages
    * Cast Button
    * Chromecast connection
* iOS:
    * Not implemented yet

## Setup

#### Add Dependency

Clone this repo and add the following piece of code to your app's pubspec

```yaml
dependencies:
  flutter_cast_framework:
    path: ../flutter_cast_framework/ # the path depends on where you cloned this repo
```

### Android Setup

#### 1. Create `CastOptionsProvider`

Add the following class to your Android project:

```kotlin
import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider

class CastOptionsProvider : OptionsProvider {
    override fun getCastOptions(context: Context): CastOptions {
        return CastOptions.Builder()
                .setReceiverApplicationId("4F8B3483")
                .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? {
        return null
    }
}
```

#### 2. Load `CastOptionsProvider`

Add the following entry in the `AndroidManifest.xml` file under the `<application>` tag to reference the `CastOptionsProvider` class:

```xml
<application>
    <meta-data
        android:name="com.google.android.gms.cast.framework.OPTIONS_PROVIDER_CLASS_NAME"
        android:value="com.gianlucaparadise.flutter_cast_framework_example.CastOptionsProvider" />
</application>
```

#### 3. Theme

Make sure that your application and your activity are using an `AppCompat` theme (as stated [here](https://developers.google.com/cast/docs/android_sender/integrate#androidtheme)).

## Tech notes

I used this project to test the capabilities of the following technologies:

* Chromecast API (Sender - Android SDK)
* Flutter
* Flutter custom platform-specific code