import UIKit
import Flutter
import GoogleCast

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GCKLoggerDelegate {
    let kReceiverAppID = "4F8B3483"
    let kDebugLoggingEnabled = true
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        // todo: find a way to init chromecast inside library
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)

        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - GCKLoggerDelegate
    
    func logMessage(_ message: String,
                    at level: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String) {
        if (kDebugLoggingEnabled) {
            print(function + " - " + message)
        }
    }
}
