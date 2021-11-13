import Flutter
import UIKit
import GoogleCast

public class SwiftFlutterCastFrameworkPlugin: NSObject, FlutterPlugin, GCKSessionManagerListener, CastHostApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let flutterApi = CastFlutterApi.init(binaryMessenger: messenger)
        
        let instance = SwiftFlutterCastFrameworkPlugin(flutterApi: flutterApi)
        
        let channel = FlutterMethodChannel(name: "flutter_cast_framework_dummy_channel", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let api : CastHostApi & NSObjectProtocol = instance
        CastHostApiSetup(messenger, api)
    }
    
    private let castContext: GCKCastContext
    private var castStateObserver: NSKeyValueObservation?
    private let flutterApi : CastFlutterApi
    
    private let sessionManager: GCKSessionManager
    
    private var castingChannels: Dictionary<String, MessageCastingChannel> = [:]
    
    var _castSession: GCKCastSession?
    var castSession: GCKCastSession? {
        get { return _castSession }
        set {
            print("Updating castSession - castSession changed: \(_castSession != newValue)")
            
            let oldSession = _castSession
            let newSession = newValue
            
            _castSession = newValue

            flutterApi.getSessionMessageNamespaces { (namespaces, err) in
                print("Updating castSession - getSessionMessageNamespaces success - param: \(namespaces.joined(separator: ", "))")
                if (oldSession == nil && newSession == nil) {
                    return // nothing to do here
                }
                
                if (namespaces.count == 0) {
                    return  // nothing to do here
                }
                
                // removing castingChannels from old session
                if (oldSession != nil && self.castingChannels.count != 0) {
                    self.castingChannels.values.forEach { (castingChannel) in
                        oldSession?.remove(castingChannel)
                    }
                }

                namespaces.forEach({ (namespace) in
                    let castingChannel = MessageCastingChannel.init(namespace: namespace, flutterApi: self.flutterApi)
                    self.castingChannels[namespace] = castingChannel
                    newSession?.add(castingChannel)
                })
            }
        }
    }
    
    init(flutterApi : CastFlutterApi) {
        self.castContext = GCKCastContext.sharedInstance()
        self.sessionManager = GCKCastContext.sharedInstance().sessionManager
        
        self.flutterApi = flutterApi
        
        super.init()
        
        self.castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        self.castStateObserver = GCKCastContext.sharedInstance().observe(\.castState, changeHandler: onCastStateChanged)
        
        let notificationCenter = NotificationCenter.default
        let app = UIApplication.shared
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: app)
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: app)
        //notificationCenter.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: app)
        //notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: app)
        //notificationCenter.addObserver(self, selector: #selector(appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: app)
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
    
    private func onCastStateChanged(state: GCKCastContext, change: NSKeyValueObservedChange<GCKCastState>) {
        let castState = GCKCastContext.sharedInstance().castState
        print("cast state change to: \(castState.rawValue)")
        notifyCastState(castState: castState)
    }
    
    private func notifyCastState(castState: GCKCastState) {
        let castStateRaw = castState.rawValue
        // Android CastStates are 1-to-4, while iOS CastStates are 0-to-3. I align iOS to Android by adding 1
        let castStateRawAdjusted = castStateRaw + 1
        self.flutterApi.onCastStateChangedCastState(NSNumber(value: castStateRawAdjusted)) { (_: Error?) in
            
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Method [\(call.method)] is not implemented.")
    }
    
    deinit {
        castStateObserver?.invalidate()
        castStateObserver = nil
    }
    
    public func sendMessageMessage(_ message: CastMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        MessageCastingChannel.sendMessage(allCastingChannels: self.castingChannels, castMessage: message)
    }
    
    public func showCastDialogWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        castContext.presentCastDialog()
    }
    
    public func loadMediaLoadRequestDataRequest(_ request: MediaLoadRequestData, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let remoteMediaClient = castSession?.remoteMediaClient
        if remoteMediaClient == nil {
            return
        }
        
        let mediaLoadRequest = getMediaLoadRequest(request: request)
        remoteMediaClient?.loadMedia(with: mediaLoadRequest)
    }
    
    // MARK: - GCKSessionManagerListener
    
    // onSessionSuspended
    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        print("SessionListener: didSuspend")
        flutterApi.onSessionSuspended { (_:Error?) in
        }
    }
    
    // onSessionStarting
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        print("SessionListener: willStart")
        flutterApi.onSessionStarting { (_:Error?) in
        }
        
        castSession = session
    }
    
    // onSessionResuming
    public func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        print("SessionListener: willResumeCastSession")
        flutterApi.onSessionResuming { (_:Error?) in
        }
        
        castSession = session
    }
    
    // onSessionEnding
    public func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        print("SessionListener: willEnd")
        flutterApi.onSessionEnding { (_:Error?) in
        }
    }
    
    // onSessionStartFailed
    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKCastSession, withError error: Error) {
        print("SessionListener: didFailToStart")
        flutterApi.onSessionStartFailed { (_:Error?) in
        }
    }
    
    // onSessionResumeFailed - Can't find this on iOS
    
    // onSessionStarted
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        print("SessionListener: didStart")
        flutterApi.onSessionStarted { (_:Error?) in
        }
        
        castSession = session
    }
    
    // onSessionResumed
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        print("SessionListener: didResumeCastSession")
        flutterApi.onSessionResumed { (_:Error?) in
        }
        
        castSession = session
    }
    
    // onSessionEnded
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        print("SessionListener: didEnd")
        flutterApi.onSessionEnded { (_:Error?) in
        }
    }
}
