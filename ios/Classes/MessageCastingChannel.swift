//
//  MessageCastingChannel.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 16/11/2019.
//

import Foundation
import GoogleCast

class MessageCastingChannel : GCKCastChannel {
    
    let channel: FlutterMethodChannel
    let namespace: String
    
    init(namespace: String, channel: FlutterMethodChannel) {
        self.channel = channel
        self.namespace = namespace
        super.init(namespace: namespace)
    }
    
    override func didReceiveTextMessage(_ message: String) {
        print("Message received: .\(message)")
        let argsMap: NSDictionary = [
            "namespace": namespace,
            "message": message
        ]

        channel.invokeMethod(MethodNames.onMessageReceived.rawValue, arguments: argsMap)
    }
    
    public static func sendMessage(allCastingChannels: Dictionary<String, MessageCastingChannel>, castMessage: CastMessage) {
        let namespaceRaw = castMessage.namespace
        let messageRaw = castMessage.message
        
        if (namespaceRaw == nil) {
            print("Namespace not valid: can't send message")
            return
        }
        
        let namespace = namespaceRaw!
        let message = messageRaw ?? ""
        
        let castingChannel = allCastingChannels[namespace]
        
        if (castingChannel == nil) {
            print("Namespace not registered: can't send message")
        }
        
        castingChannel?.sendMessage(message: message)
    }
    
    private func sendMessage(message: String) {
        var error: GCKError?
        self.sendTextMessage(message, error: &error)
        
        if error != nil {
          print("Error sending text message \(error.debugDescription)")
        }
    }
}
