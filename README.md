# Flutter Cast Framework

## Overview

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/flutter_cast_framework?include_prereleases)

Flutter Cast Framework is a POC of a flutter plugin that lets you use Chromecast API in a flutter app.

## Useful links

* [Repository](https://github.com/gianlucaparadise/flutter_cast_framework)
* [API Docs](https://gianlucaparadise.github.io/flutter_cast_framework/api/)

## Exposed APIs

Currently only the following APIs are integrated (both Android and iOS):

* Cast State
* Session state
* Send custom message
* Listen to received custom messages
* Load RemoteMediaRequestData
* Play, Pause, Stop media
* Expanded controls
* Mini Controller
* Cast Button
* Chromecast connection

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
                .setReceiverApplicationId("4F8B3483") // Your receiver Application ID
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

### iOS Setup

#### 1. Minimum iOS version

Make sure you minimum iOS version is 10.0.
Select *Runner* from left pane > *General* tab > *Deployment Info* > *Target*: set 10.0 or higher

#### 2. Install iOS dependencies

When Xcode is closed, open a terminal at the root folder of your project and run:

```bash
cd ios && pod install
```

#### 3. Open project in Xcode

To open your flutter project with Xcode, from root folder run `open ios/Runner.xcworkspace`

#### 4. Chromecast SDK setup

Add the following lines to your `AppDelegate.swift`:

```diff
 import UIKit
 import Flutter
+import GoogleCast
 
 @UIApplicationMain
-@objc class AppDelegate: FlutterAppDelegate {
+@objc class AppDelegate: FlutterAppDelegate, GCKLoggerDelegate {
+  let kReceiverAppID = "4F8B3483" // Your receiver Application ID
+  let kDebugLoggingEnabled = true
+  
   override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
   ) -> Bool {
+    let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
+    let options = GCKCastOptions(discoveryCriteria: criteria)
+    GCKCastContext.setSharedInstanceWith(options)
+
+    // Enable logger.
+    GCKLogger.sharedInstance().delegate = self
+    
     GeneratedPluginRegistrant.register(with: self)
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
   }
+  
+  // MARK: - GCKLoggerDelegate
+  
+  func logMessage(_ message: String,
+                  at level: GCKLoggerLevel,
+                  fromFunction function: String,
+                  location: String) {
+      if (kDebugLoggingEnabled) {
+          print(function + " - " + message)
+      }
+  }
 }
```

## Tech notes

I used this project to test the capabilities of the following technologies:

* Chromecast API (Sender - Android SDK)
* Flutter
* Flutter custom platform-specific code

## Roadmap

Next features to be developed:

* CC in Expanded Controls (iOS)
* Expanded Controls cosmetics (ad in progress bar, full screen, progress bar handle)
* Title in MiniController and ExpandedControls (blocked because of a [pigeon issue](https://github.com/flutter/flutter/issues/93464))
* Handle queue
* Handle progress seek
* Understand if it is better to refactor using streams instead of listeners
* Add tests