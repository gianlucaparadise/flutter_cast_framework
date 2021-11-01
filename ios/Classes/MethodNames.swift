//
//  MethodNames.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 09/11/2019.
//

import Foundation

enum MethodNames : String {
    case onCastStateChanged = "CastContext.onCastStateChanged"
    case showCastDialog = "showCastDialog"

    // region SessionManager
    case onSessionStarting = "SessionManager.onSessionStarting"
    case onSessionStarted = "SessionManager.onSessionStarted"
    case onSessionStartFailed = "SessionManager.onSessionStartFailed"
    case onSessionEnding = "SessionManager.onSessionEnding"
    case onSessionEnded = "SessionManager.onSessionEnded"
    case onSessionResuming = "SessionManager.onSessionResuming"
    case onSessionResumed = "SessionManager.onSessionResumed"
    case onSessionResumeFailed = "SessionManager.onSessionResumeFailed"
    case onSessionSuspended = "SessionManager.onSessionSuspended"
    // end-region

    case getSessionMessageNamespaces = "CastSession.getSessionMessageNamespaces"
    case onMessageReceived = "CastSession.onMessageReceived"
}
