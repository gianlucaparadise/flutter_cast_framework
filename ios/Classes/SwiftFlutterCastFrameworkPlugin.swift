import Flutter
import UIKit
import GoogleCast

public class SwiftFlutterCastFrameworkPlugin: NSObject, FlutterPlugin, GCKSessionManagerListener {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_cast_framework", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCastFrameworkPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private let castContext: GCKCastContext
    private var castStateObserver: NSKeyValueObservation?
    private let channel: FlutterMethodChannel
    
    private let sessionManager: GCKSessionManager
    
    var _castSession: GCKCastSession?
    var castSession: GCKCastSession? {
        get { return _castSession }
        set {
            print("Updating castSession - castSession changed: \(_castSession != newValue)")
            // if (_castSession == newValue) return // Despite the instances are the same, I need to re-attach the listener to every new session instance

            // val result = NamespaceResult(oldSession = field, newSession = value)

            _castSession = newValue

            // channel.invokeMethod(MethodNames.getSessionMessageNamespaces, null, result)
        }
    }
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.castContext = GCKCastContext.sharedInstance()
        self.sessionManager = GCKCastContext.sharedInstance().sessionManager
        
        super.init()
        
        self.castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        self.castStateObserver = GCKCastContext.sharedInstance().observe(\.castState, changeHandler: onCastStateChanged)
        
        let notificationCenter = NotificationCenter.default
        let app = UIApplication.shared
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: app)
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        notificationCenter.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: app)
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: app)
        notificationCenter.addObserver(self, selector: #selector(appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: app)
    }
    
    @objc func appDidBecomeActive() {
        print("AppLife: appDidBecomeActive - App moved to foreground!")
        self.sessionManager.add(self)
        self.castSession = self.sessionManager.currentCastSession
        
        notifyCastState(castState: GCKCastContext.sharedInstance().castState)
    }
    
    @objc func appWillResignActive() {
        print("AppLife: appWillResignActive - App moved to background!")
        self.sessionManager.remove(self)
        self.castSession = nil
    }
    
    @objc func appDidEnterBackground() {
        print("AppLife: appDidEnterBackground")
    }
    
    @objc func appWillEnterForeground() {
        print("AppLife: appWillEnterForeground")
    }
    
    @objc func appWillTerminate() {
        print("AppLife: appWillTerminate")
    }
    
    private func onCastStateChanged(state: GCKCastContext, change: NSKeyValueObservedChange<GCKCastState>) {
        let castState = GCKCastContext.sharedInstance().castState
        print("cast state change to: \(castState.rawValue)")
        notifyCastState(castState: castState)
    }
    
    private func notifyCastState(castState: GCKCastState) {
        let castStateRaw = castState.rawValue
        // Android CastStates are 1-to-4, while iOS CastStates are 0-to-3. I align iOS to Android by adding 1
        let castStateRawAdjusted = castStateRaw + 1
        self.channel.invokeMethod(MethodNames.onCastStateChanged.rawValue, arguments: castStateRawAdjusted)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodNames.showCastDialog.rawValue:
            castContext.presentCastDialog()
        default:
            print("Method [\(call.method)] is not implemented.")
        }
    }
    
    deinit {
        castStateObserver?.invalidate()
        castStateObserver = nil
    }
    
    // MARK: - GCKSessionManagerListener
    
    // onSessionSuspended
    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        print("SessionListener: didSuspend")
        channel.invokeMethod(MethodNames.onSessionSuspended.rawValue, arguments: nil)
    }
    
    // onSessionStarting
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        print("SessionListener: willStart")
        channel.invokeMethod(MethodNames.onSessionStarting.rawValue, arguments: nil)
        
        castSession = session
    }
    
    // onSessionResuming
    public func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        print("SessionListener: willResumeCastSession")
        channel.invokeMethod(MethodNames.onSessionResuming.rawValue, arguments: nil)
        
        castSession = session
    }
    
    // onSessionEnding
    public func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        print("SessionListener: willEnd")
        channel.invokeMethod(MethodNames.onSessionEnding.rawValue, arguments: nil)
    }
    
    // onSessionStartFailed
    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKCastSession, withError error: Error) {
        print("SessionListener: didFailToStart")
        channel.invokeMethod(MethodNames.onSessionStartFailed.rawValue, arguments: nil)
    }
    
    // onSessionResumeFailed - Can't find this on iOS
    
    // onSessionStarted
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        print("SessionListener: didStart")
        channel.invokeMethod(MethodNames.onSessionStarted.rawValue, arguments: nil)
        
        castSession = session
    }
    
    // onSessionResumed
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        print("SessionListener: didResumeCastSession")
        channel.invokeMethod(MethodNames.onSessionResumed.rawValue, arguments: nil)
        
        castSession = session
    }
    
    // onSessionEnded
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        print("SessionListener: didEnd")
        channel.invokeMethod(MethodNames.onSessionEnded.rawValue, arguments: nil)
    }
}
