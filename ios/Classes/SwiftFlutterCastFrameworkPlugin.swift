import Flutter
import UIKit
import GoogleCast

public class SwiftFlutterCastFrameworkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_cast_framework", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCastFrameworkPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    let castContext: GCKCastContext
    var stateObserver: NSKeyValueObservation?
    var channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.castContext = GCKCastContext.sharedInstance()
        self.stateObserver = GCKCastContext.sharedInstance().observe(\.castState, options: [.new, .old, .initial]){ (state, change) in
            let castStateRaw = GCKCastContext.sharedInstance().castState.rawValue
            // Android CastStates are 1-to-4, while iOS CastStates are 0-to-3. I align iOS to Android by adding 1
            let castStateRawAdjusted = castStateRaw + 1
            print("cast state change to: \(castStateRawAdjusted)")
            channel.invokeMethod(MethodNames.onCastStateChanged.rawValue, arguments: castStateRawAdjusted)
        }
        super.init()
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
        stateObserver?.invalidate()
        stateObserver = nil
    }
}
