package com.gianlucaparadise.flutter_cast_framework

object MethodNames {
    const val onCastStateChanged = "CastContext.onCastStateChanged"
    const val showCastDialog = "showCastDialog"

    // region SessionManager
    const val onSessionStarting = "SessionManager.onSessionStarting"
    const val onSessionStarted = "SessionManager.onSessionStarted"
    const val onSessionStartFailed = "SessionManager.onSessionStartFailed"
    const val onSessionEnding = "SessionManager.onSessionEnding"
    const val onSessionEnded = "SessionManager.onSessionEnded"
    const val onSessionResuming = "SessionManager.onSessionResuming"
    const val onSessionResumed = "SessionManager.onSessionResumed"
    const val onSessionResumeFailed = "SessionManager.onSessionResumeFailed"
    const val onSessionSuspended = "SessionManager.onSessionSuspended"
    // end-region

    const val getSessionMessageNamespaces = "CastSession.getSessionMessageNamespaces"
    const val onMessageReceived = "CastSession.onMessageReceived"
}