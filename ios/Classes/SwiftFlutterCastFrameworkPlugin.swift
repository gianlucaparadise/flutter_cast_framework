import Flutter
import UIKit
import GoogleCast

public class SwiftFlutterCastFrameworkPlugin: NSObject, FlutterPlugin, GCKSessionManagerListener, CastHostApi, GCKRemoteMediaClientListener, GCKMediaQueueDelegate {
    
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
    private var progressTimer: Timer?
    
    private let sessionManager: GCKSessionManager
    
    private var castingChannels: Dictionary<String, MessageCastingChannel> = [:]
    
    var _castSession: GCKCastSession?
    var castSession: GCKCastSession? {
        get { return _castSession }
        set {
            debugPrint("Updating castSession - castSession changed: \(_castSession != newValue)")
            
            let oldSession = _castSession
            let newSession = newValue
            
            _castSession = newValue
            
            remoteMediaClient = newValue?.remoteMediaClient
            
            flutterApi.getSessionMessageNamespaces { (namespaces, err) in
                debugPrint("Updating castSession - getSessionMessageNamespaces success - param: \(String(describing: namespaces?.joined(separator: ", ")))")
                if (oldSession == nil && newSession == nil) {
                    return // nothing to do here
                }
                
                if (namespaces == nil || namespaces?.count == 0) {
                    return  // nothing to do here
                }
                
                // removing castingChannels from old session
                if (oldSession != nil && self.castingChannels.count != 0) {
                    self.castingChannels.values.forEach { (castingChannel) in
                        oldSession?.remove(castingChannel)
                    }
                }

                namespaces?.forEach({ (namespace) in
                    let castingChannel = MessageCastingChannel.init(namespace: namespace, flutterApi: self.flutterApi)
                    self.castingChannels[namespace] = castingChannel
                    newSession?.add(castingChannel)
                })
            }
        }
    }
    
    var _remoteMediaClient: GCKRemoteMediaClient?
    var remoteMediaClient: GCKRemoteMediaClient? {
        get { return _remoteMediaClient }
        set {
            debugPrint("Updating remoteMediaClient - remoteMediaClient changed: \(_remoteMediaClient != newValue)")
            
            _remoteMediaClient?.remove(self)
            newValue?.add(self)
            
            _remoteMediaClient = newValue
            mediaQueue = newValue?.mediaQueue
        }
    }
    
    var _mediaQueue: GCKMediaQueue?
    var mediaQueue: GCKMediaQueue? {
        get { return _mediaQueue }
        set {
            debugPrint("Updating mediaQueue - mediaQueue changed: \(_mediaQueue != newValue)")
            
            _mediaQueue?.remove(self)
            newValue?.add(self)
            
            _mediaQueue = newValue
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
        debugPrint("AppLife: appDidBecomeActive - App moved to foreground!")
        self.sessionManager.add(self)
        self.castSession = self.sessionManager.currentCastSession
        
        notifyCastState(castState: GCKCastContext.sharedInstance().castState)
    }
    
    @objc func appWillResignActive() {
        debugPrint("AppLife: appWillResignActive - App moved to background!")
        self.sessionManager.remove(self)
        self.castSession = nil
    }
    
    private func onCastStateChanged(state: GCKCastContext, change: NSKeyValueObservedChange<GCKCastState>) {
        let castState = GCKCastContext.sharedInstance().castState
        debugPrint("cast state change to: \(castState.rawValue)")
        notifyCastState(castState: castState)
    }
    
    private func notifyCastState(castState: GCKCastState) {
        let castStateRaw = castState.rawValue
        // Android CastStates are 1-to-4, while iOS CastStates are 0-to-3. I align iOS to Android by adding 1
        let castStateRawAdjusted = castStateRaw + 1
        self.flutterApi.onCastStateChangedCastState(NSNumber(value: castStateRawAdjusted)) { (_: FlutterError?) in
            
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Method [\(call.method)] is not implemented.")
    }
    
    deinit {
        castStateObserver?.invalidate()
        castStateObserver = nil
        stopProgressTimer()
    }
    
    func startProgressTimer() {
        if progressTimer != nil {
            return
        }
        
        if #available(iOS 10.0, *) {
            debugPrint("ProgressTimer: creating progress timer")
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: onProgressTimerFired)
            RunLoop.current.add(timer, forMode: .common)
            progressTimer = timer
        } else {
            debugPrint("ProgressTimer: can't create progress timer")
        }
    }
    
    private func onProgressTimerFired(t: Timer) {
        let adBreakStatus = remoteMediaClient?.mediaStatus?.adBreakStatus
        let adBreakId = adBreakStatus?.adBreakID
        let adBreakClipId = adBreakStatus?.adBreakClipID
        
        if (adBreakId?.isEmpty == false || adBreakClipId?.isEmpty == false) {
            // There is an ad ongoing
            fireAdBreakProgressUpdate()
        }
        else {
            currentAdBreakClipProgress = -1
            currentAdBreakClipId = ""
            fireMediaProgressUpdate()
        }
    }
    
    private var currentAdBreakClipProgress = -1 // in seconds
    private var currentAdBreakClipId = ""
    
    private func calculateCurrentAdBreakClipProgress(adBreakClipId: String) -> Int {
        if currentAdBreakClipProgress < 0 || currentAdBreakClipId != adBreakClipId {
            // In this case, the ad break clip has just started
            currentAdBreakClipId = adBreakClipId
        }
        
        currentAdBreakClipProgress += 1
        return currentAdBreakClipProgress
    }
    
    private func fireAdBreakProgressUpdate() {
        let mediaStatus = remoteMediaClient?.mediaStatus
        let adBreakStatus = mediaStatus?.adBreakStatus
        if (adBreakStatus == nil) {
            return
        }
        
        let adBreakId = adBreakStatus?.adBreakID ?? ""
        let adBreakClipId = adBreakStatus?.adBreakClipID ?? ""
        let adBreakClipProgressSecs = calculateCurrentAdBreakClipProgress(adBreakClipId: adBreakClipId)
        let whenSkippableSecs = adBreakStatus?.whenSkippable ?? 0
        
        let adBreakClip = mediaStatus?.mediaInformation?.adBreakClips?.first(where: { (ad:GCKAdBreakClipInfo) -> Bool in
            ad.adBreakClipID == adBreakClipId
        })
        
        if (adBreakClip == nil) {
            return
        }
        
        let adBreakClipDurationSecs = adBreakClip?.duration ?? 0
        
        let adBreakClipProgressMs = adBreakClipProgressSecs * 1000
        let whenSkippableMs = Int(whenSkippableSecs * 1000)
        let adBreakClipDurationMs = Int(adBreakClipDurationSecs * 1000)
        
        let nsAdBreakClipProgress = NSNumber(value: adBreakClipProgressMs)
        let nsWhenSkippable = NSNumber(value: whenSkippableMs)
        let nsAdBreakClipDuration = NSNumber(value: adBreakClipDurationMs)
        
        DispatchQueue.main.async {
            self.flutterApi.onAdBreakClipProgressUpdatedAdBreakId(adBreakId, adBreakClipId: adBreakClipId, progressMs: nsAdBreakClipProgress, durationMs: nsAdBreakClipDuration, whenSkippableMs: nsWhenSkippable) { (_:FlutterError?) in
            }
        }
    }
    
    private func fireMediaProgressUpdate() {
        let durationSecs = remoteMediaClient?.mediaStatus?.mediaInformation?.streamDuration ?? 0
        let progressInterval = remoteMediaClient?.approximateStreamPosition() ?? 0
        
        let durationMs = Int(durationSecs * 1000)
        let progressMs = Int(progressInterval * 1000)
        
        let nsDuration = NSNumber(value: durationMs)
        let nsProgress = NSNumber(value: progressMs)
        
        DispatchQueue.main.async {
            self.flutterApi.onProgressUpdatedProgressMs(nsProgress, durationMs: nsDuration) { (_:FlutterError?) in
            }
        }
    }
    
    func stopProgressTimer() {
        debugPrint("ProgressTimer: stopping progress timer")
        progressTimer?.invalidate()
        progressTimer = nil
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
    
    public func getMediaInfoWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> MediaInfo? {
        let hostMediaInfo = remoteMediaClient?.mediaStatus?.mediaInformation
        
        if (hostMediaInfo == nil) {
            return MediaInfo()
        }
        
        return getFlutterMediaInfo(mediaInfo: hostMediaInfo)
    }
    
    public func playWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        remoteMediaClient?.play()
    }
    
    public func pauseWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        remoteMediaClient?.pause()
    }
    
    public func stopWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        remoteMediaClient?.stop()
    }
    
    public func setMuteMuted(_ muted: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if (castSession == nil) {
            return
        }
        let isMuted = muted == 1
        castSession?.setDeviceMuted(isMuted)
    }
    
    public func seek(toPosition position: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let options = GCKMediaSeekOptions()
        options.interval = position.doubleValue / 1000
        options.resumeState = .unchanged
        
        remoteMediaClient?.seek(with: options)
    }
    
    
    public func getCastDeviceWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> CastDevice? {
        let castDevice = castSession?.device
        
        if (castDevice == nil) {
            return CastDevice()
        }
        
        let result = CastDevice()
        
        result.deviceId = castDevice?.deviceID
        result.friendlyName = castDevice?.friendlyName
        result.modelName = castDevice?.modelName
        
        return result
    }
    
    public func showTracksChooserDialogWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // let dialog = GCKUIMediaTrackSelectionViewController.init()
        // let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        //
        // if (rootViewController is UINavigationController) {
        //     debugPrint("showTracksChooserDialog: rootViewController is UINavigationController")
        //     (rootViewController as! UINavigationController).pushViewController(dialog,animated:true)
        // } else if rootViewController != nil {
        //     debugPrint("showTracksChooserDialog: rootViewController is UINavigationController")
        //     let navigationController = UINavigationController(rootViewController:dialog)
        //     rootViewController?.present(navigationController, animated:true, completion:nil)
        // }
        // else {
        //     debugPrint("showTracksChooserDialog: missing rootViewController")
        // }
        // TODO: implement this feature
        print("showTracksChooserDialog: unsupported feature")
    }
    
    public func skipAdWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        remoteMediaClient?.skipAd()
    }
    
    public func queueAppendItemItem(_ item: MediaQueueItem, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let remoteMediaClient = castSession?.remoteMediaClient
        if remoteMediaClient == nil {
            return
        }
        
        let mediaQueueItem = getMediaQueueItem(item: item)
        // as per documentation: If beforeItemWithID is kGCKMediaQueueInvalidItemID, the inserted item will be appended to the end of the queue
        remoteMediaClient?.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
    }
    
    public func queueNextItemWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let remoteMediaClient = castSession?.remoteMediaClient
        remoteMediaClient?.queueNextItem()
    }
    
    public func queuePrevItemWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let remoteMediaClient = castSession?.remoteMediaClient
        remoteMediaClient?.queuePreviousItem()
    }
    
    public func getQueueItemCountWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        if (mediaQueue == nil) {
            return -1
        }
        
        let itemCount = mediaQueue?.itemCount ?? 0
        return NSNumber(value: itemCount)
    }
    
    public func getQueueItem(atIndexIndex index: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> MediaQueueItem? {
        if (index.intValue < 0) {
            return getFlutterMediaQueueItem(item: nil)
        }
        
        let mediaQueueItem = mediaQueue?.item(at: index.uintValue, fetchIfNeeded: true)
        return getFlutterMediaQueueItem(item: mediaQueueItem)
    }
    
    // MARK: - GCKSessionManagerListener
    
    // onSessionSuspended
    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        debugPrint("SessionListener: didSuspend")
        flutterApi.onSessionSuspended { (_:FlutterError?) in
        }
    }
    
    // onSessionStarting
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        debugPrint("SessionListener: willStart")
        flutterApi.onSessionStarting { (_:FlutterError?) in
        }
        
        castSession = session
    }
    
    // onSessionResuming
    public func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        debugPrint("SessionListener: willResumeCastSession")
        flutterApi.onSessionResuming { (_:FlutterError?) in
        }
        
        castSession = session
    }
    
    // onSessionEnding
    public func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        debugPrint("SessionListener: willEnd")
        stopProgressTimer()
        flutterApi.onSessionEnding { (_:FlutterError?) in
        }
    }
    
    // onSessionStartFailed
    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKCastSession, withError error: Error) {
        debugPrint("SessionListener: didFailToStart")
        flutterApi.onSessionStartFailed { (_:FlutterError?) in
        }
    }
    
    // onSessionResumeFailed - Can't find this on iOS
    
    // onSessionStarted
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        debugPrint("SessionListener: didStart")
        flutterApi.onSessionStarted { (_:FlutterError?) in
        }
        
        castSession = session
    }
    
    // onSessionResumed
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        debugPrint("SessionListener: didResumeCastSession")
        flutterApi.onSessionResumed { (_:FlutterError?) in
        }
        
        castSession = session
    }
    
    // onSessionEnded
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        debugPrint("SessionListener: didEnd")
        flutterApi.onSessionEnded { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClientDidUpdateQueue(_ client: GCKRemoteMediaClient) {
        debugPrint("RemoteMediaClientListener: didUpdateQueue")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onPreloadStatusUpdated
    public func remoteMediaClientDidUpdatePreloadStatus(_ client: GCKRemoteMediaClient) {
        debugPrint("RemoteMediaClientListener: didUpdatePreloadStatus")
        flutterApi.onPreloadStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        var playerStateLabel = ""
        
        switch mediaStatus?.playerState {
        case .unknown:
            playerStateLabel = "PlayerStateUnknown"
        case .idle:
            playerStateLabel = "PlayerStateIdle"
        case .playing:
            playerStateLabel = "PlayerStatePlaying"
            startProgressTimer()
        case .paused:
            playerStateLabel = "PlayerStatePaused"
            stopProgressTimer()
        case .buffering:
            playerStateLabel = "PlayerStateBuffering"
            stopProgressTimer()
        case .loading:
            playerStateLabel = "PlayerStateLoading"
            startProgressTimer()
        default: break
        }
        
        debugPrint("RemoteMediaClientListener: didUpdate mediaStatus - playerState: \(playerStateLabel)")
        let flutterMediaStatus = getFlutterMediaStatus(mediaStatus: mediaStatus)
        flutterApi.onStatusUpdatedMediaStatus(flutterMediaStatus) { (_:FlutterError?) in
        }
        flutterApi.onAdBreakStatusUpdatedMediaStatus(flutterMediaStatus) { (_:FlutterError?) in
        }
    }
    
    // onAdBreakStatusUpdated - Can't find this on iOS
    // onMediaError - Can't find this on iOS
    
    // onMetadataUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaMetadata: GCKMediaMetadata?) {
        debugPrint("RemoteMediaClientListener: didUpdate mediaMetadata")
        flutterApi.onMetadataUpdated { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didReceive queueItems: [GCKMediaQueueItem]) {
        debugPrint("RemoteMediaClientListener: didReceive queueItems")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onSendingRemoteMediaRequest
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didStartMediaSessionWithID sessionID: Int) {
        debugPrint("RemoteMediaClientListener: didStartMediaSessionWithID")
        flutterApi.onSendingRemoteMediaRequest { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didReceiveQueueItemIDs queueItemIDs: [NSNumber]) {
        debugPrint("RemoteMediaClientListener: didReceiveQueueItemIDs")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdateQueueItemsWithIDs queueItemIDs: [NSNumber]) {
        debugPrint("RemoteMediaClientListener: didUpdateQueueItemsWithIDs")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didRemoveQueueItemsWithIDs queueItemIDs: [NSNumber]) {
        debugPrint("RemoteMediaClientListener: didRemoveQueueItemsWithIDs")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // onQueueStatusUpdated
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didInsertQueueItemsWithIDs queueItemIDs: [NSNumber], beforeItemWithID beforeItemID: UInt) {
        debugPrint("RemoteMediaClientListener: didInsertQueueItemsWithIDs")
        flutterApi.onQueueStatusUpdated { (_:FlutterError?) in
        }
    }
    
    // mediaQueueWillChange
    public func mediaQueueWillChange(_ queue: GCKMediaQueue) {
        debugPrint("MediaQueueListener: mediaQueueWillChange")
        flutterApi.mediaQueueWillChange { (_:FlutterError?) in
        }
    }
    
    // mediaQueueChanged
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        debugPrint("MediaQueueListener: mediaQueueDidChange")
        flutterApi.mediaQueueChanged { (_:FlutterError?) in
        }
    }
    
    // itemsReloaded
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        debugPrint("MediaQueueListener: mediaQueueDidReloadItems")
        flutterApi.itemsReloaded { (_:FlutterError?) in
        }
    }
    
    // itemsInsertedInRange
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        debugPrint("MediaQueueListener: mediaQueueDidInsertItemsIn")
        let count = range.upperBound - range.lowerBound
        let start = range.lowerBound
        flutterApi.itemsInserted(inRangeInsertIndex: NSNumber(value: start), insertCount: NSNumber(value: count)) { (_:FlutterError?) in
        }
    }
    
    // itemsUpdatedAtIndexes
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        debugPrint("MediaQueueListener: mediaQueueDidUpdateItemsAtIndexes")
        flutterApi.itemsUpdated(atIndexesIndexes: indexes) { (_:FlutterError?) in
        }
    }
    
    // itemsRemovedAtIndexes
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        debugPrint("MediaQueueListener: mediaQueueDidRemoveItemsAtIndexes")
        flutterApi.itemsRemoved(atIndexesIndexes: indexes) { (_:FlutterError?) in
        }
    }
    
    //  itemsReorderedAtIndexes - Can't find on iOS
}
