//
//  MessageCastingChannel.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 16/11/2019.
//

import Foundation
import GoogleCast

class MessageCastingChannel : GCKCastChannel {
    
    let flutterApi: CastFlutterApi
    let namespace: String
    
    init(namespace: String, flutterApi: CastFlutterApi) {
        self.flutterApi = flutterApi
        self.namespace = namespace
        super.init(namespace: namespace)
    }
    
    override func didReceiveTextMessage(_ message: String) {
        print("Message received: .\(message)")
        let castMessage = CastMessage.init()
        castMessage.namespace = namespace
        castMessage.message = message
        
        flutterApi.onMessageReceivedMessage(castMessage) { (_: Error?) in
        }
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
