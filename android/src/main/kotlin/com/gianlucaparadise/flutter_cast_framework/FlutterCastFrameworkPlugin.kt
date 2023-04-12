package com.gianlucaparadise.flutter_cast_framework

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.*
import com.gianlucaparadise.flutter_cast_framework.cast.CastDialogOpener
import com.gianlucaparadise.flutter_cast_framework.cast.MessageCastingChannel
import com.gianlucaparadise.flutter_cast_framework.media.*
import com.google.android.gms.cast.MediaError
import com.google.android.gms.cast.MediaSeekOptions
import com.google.android.gms.cast.MediaStatus.*
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.MediaQueue
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.cast.framework.media.TracksChooserDialogFragment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterCastFrameworkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, DefaultLifecycleObserver {
    companion object {
        const val TAG = "AndroidCastPlugin"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterCastFrameworkPlugin()
            plugin.onAttachedToEngine(registrar.context(), registrar.messenger())
        }
    }

    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    //region FlutterPlugin interface
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        this.applicationContext = applicationContext

        castApi = MyApi()
        PlatformBridgeApis.CastHostApi.setup(messenger, castApi)

        val castFlutterApi = PlatformBridgeApis.CastFlutterApi(messenger)
        flutterApi = castFlutterApi

        mMessageCastingChannel = MessageCastingChannel(castFlutterApi)

        CastContext.getSharedInstance(applicationContext, ).addCastStateListener { i ->
            Log.d(TAG, "Cast state changed: $i")
            flutterApi?.onCastStateChanged(i.toLong()) { }
        }

        mSessionManager = CastContext.getSharedInstance(applicationContext).sessionManager
        mCastSession = mSessionManager.currentCastSession
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        applicationContext = null
        mMessageCastingChannel = null
    }
    //endregion

    //region ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        activity = null
    }
    //endregion

    private lateinit var mSessionManager: SessionManager
    private val mSessionManagerListener = CastSessionManagerListener()
    private val remoteMediaClientListener = RemoteMediaClientListener()
    private val mediaQueueListener = MediaQueueListener()

    private var castApi: PlatformBridgeApis.CastHostApi? = null
    private var flutterApi: PlatformBridgeApis.CastFlutterApi? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    private var mMessageCastingChannel: MessageCastingChannel? = null

    private var mCastSession: CastSession? = null
        set(value) {
            Log.d(TAG, "Updating mCastSession - castSession changed: ${field != value}")
            // if (field == value) return // Despite the instances are the same, I need to re-attach the listener to every new session instance

            val oldSession = field
            field = value

            remoteMediaClient = value?.remoteMediaClient
            flutterApi?.getSessionMessageNamespaces(getOnNamespaceResult(oldSession, newSession = value))
        }

    private var remoteMediaClient: RemoteMediaClient? = null
        set(value) {
            Log.d(TAG, "Updating remoteMediaClient - remoteMediaClient changed: ${field != value}")

            field?.unregisterCallback(remoteMediaClientListener)
            value?.registerCallback(remoteMediaClientListener)

            // Amount of time in milliseconds between subsequent updates
            val periodMs = 1000L
            field?.removeProgressListener(remoteMediaClientListener)
            value?.addProgressListener(remoteMediaClientListener, periodMs)

            field = value

            mediaQueue = value?.mediaQueue
        }

    private var mediaQueue: MediaQueue? = null
        set(value) {
            Log.d(TAG, "Updating mediaQueue - mediaQueue changed: ${field != value}")

            field?.unregisterCallback(mediaQueueListener)
            value?.registerCallback(mediaQueueListener)

            field = value
        }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        Log.d(TAG, "App: ON_CREATE")
    }

    override fun onResume(owner: LifecycleOwner) {
        Log.d(TAG, "App: ON_RESUME")
        mSessionManager.addSessionManagerListener(mSessionManagerListener, CastSession::class.java)
        mCastSession = mSessionManager.currentCastSession

        val context = applicationContext
        if (context == null) {
            Log.d(TAG, "App: ON_RESUME - missing context")
            return
        }
        val castState = CastContext.getSharedInstance(context).castState
        flutterApi?.onCastStateChanged(castState.toLong()) { }
    }

    override fun onPause(owner: LifecycleOwner) {
        Log.d(TAG, "App: ON_PAUSE")
        mSessionManager.removeSessionManagerListener(
                mSessionManagerListener,
                CastSession::class.java
        )
        // I can't set this to null because I need the cast session to send commands from notification
        // mCastSession = null
    }
    //endregion

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "onMethodCall - ${call.method} not implemented")
        result.notImplemented()
    }

    private inner class RemoteMediaClientListener : RemoteMediaClient.Callback(), RemoteMediaClient.ProgressListener {
        override fun onStatusUpdated() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            val mediaStatus = remoteMediaClient.mediaStatus ?: return

            val playerStateLabel = when (remoteMediaClient.playerState) {
                PLAYER_STATE_UNKNOWN -> "unknown"
                PLAYER_STATE_BUFFERING -> "buffering"
                PLAYER_STATE_IDLE -> "idle"
                PLAYER_STATE_LOADING -> "loading"
                PLAYER_STATE_PAUSED -> "paused"
                PLAYER_STATE_PLAYING -> "playing"
                else -> "unknown-else"
            }
            Log.d(TAG, "RemoteMediaClient - onStatusUpdated: $playerStateLabel")
            super.onStatusUpdated()

            val flutterMediaStatus = getFlutterMediaStatus(mediaStatus)
            flutterApi?.onStatusUpdated(flutterMediaStatus) { }
        }

        override fun onMetadataUpdated() {
            Log.d(TAG, "RemoteMediaClient - onMetadataUpdated")
            super.onMetadataUpdated()
            flutterApi?.onMetadataUpdated { }
        }

        override fun onQueueStatusUpdated() {
            Log.d(TAG, "RemoteMediaClient - onQueueStatusUpdated")
            super.onQueueStatusUpdated()
            flutterApi?.onQueueStatusUpdated { }
        }

        override fun onPreloadStatusUpdated() {
            Log.d(TAG, "RemoteMediaClient - onPreloadStatusUpdated")
            super.onPreloadStatusUpdated()
            flutterApi?.onPreloadStatusUpdated { }
        }

        override fun onSendingRemoteMediaRequest() {
            Log.d(TAG, "RemoteMediaClient - onSendingRemoteMediaRequest")
            super.onSendingRemoteMediaRequest()
            flutterApi?.onSendingRemoteMediaRequest { }
        }

        override fun onAdBreakStatusUpdated() {
            val mediaStatus = remoteMediaClient?.mediaStatus ?: return

            val isPlayingAd = mediaStatus.isPlayingAd
            Log.d(TAG, "RemoteMediaClient - onAdBreakStatusUpdated - isPlayingAd: $isPlayingAd")
            super.onAdBreakStatusUpdated()

            val flutterMediaStatus = getFlutterMediaStatus(mediaStatus)
            flutterApi?.onAdBreakStatusUpdated(flutterMediaStatus) { }
        }

        override fun onMediaError(error: MediaError) {
            Log.d(TAG, "RemoteMediaClient - onMediaError $error")
            super.onMediaError(error)
            flutterApi?.onMediaError { }
        }

        override fun onProgressUpdated(progressMs: Long, durationMs: Long) {
            val isPlayingAd = remoteMediaClient?.mediaStatus?.isPlayingAd ?: false
            if (isPlayingAd) {
                fireAdBreakClipProgress()
            } else {
                flutterApi?.onProgressUpdated(progressMs, durationMs) { }
            }
        }

        fun fireAdBreakClipProgress() {
            val mediaStatus = remoteMediaClient?.mediaStatus ?: return
            val currentAdBreakClip = mediaStatus.currentAdBreakClip ?: return

            val adBreakId = mediaStatus.currentAdBreak?.id ?: ""
            val adBreakClipId = currentAdBreakClip.id ?: ""
            val adBreakClipProgressMs = remoteMediaClient?.approximateAdBreakClipPositionMs
                    ?: 0
            val adBreakClipDurationMs = currentAdBreakClip.durationInMs
            if (adBreakClipDurationMs <= 0) return

            val whenSkippableMs = currentAdBreakClip.whenSkippableInMs

            flutterApi?.onAdBreakClipProgressUpdated(
                    adBreakId,
                    adBreakClipId,
                    adBreakClipProgressMs,
                    adBreakClipDurationMs,
                    whenSkippableMs,
            ) { }
        }
    }

    private inner class MediaQueueListener : MediaQueue.Callback() {
        override fun mediaQueueWillChange() {
            Log.d(TAG, "MediaQueue - mediaQueueWillChange")
            super.mediaQueueWillChange()
            flutterApi?.mediaQueueWillChange { }
        }

        override fun mediaQueueChanged() {
            Log.d(TAG, "MediaQueue - mediaQueueChanged")
            super.mediaQueueChanged()
            flutterApi?.mediaQueueChanged { }
        }

        override fun itemsReloaded() {
            Log.d(TAG, "MediaQueue - itemsReloaded")
            super.itemsReloaded()
            flutterApi?.itemsReloaded { }
        }

        override fun itemsInsertedInRange(insertIndex: Int, insertCount: Int) {
            Log.d(TAG, "MediaQueue - itemsInsertedInRange")
            super.itemsInsertedInRange(insertIndex, insertCount)
            flutterApi?.itemsInsertedInRange(insertIndex.toLong(), insertCount.toLong()) { }
        }

        override fun itemsUpdatedAtIndexes(indexes: IntArray) {
            Log.d(TAG, "MediaQueue - itemsUpdatedAtIndexes")
            super.itemsUpdatedAtIndexes(indexes)

            val longIndexes = indexes.map { it.toLong() }
            flutterApi?.itemsUpdatedAtIndexes(longIndexes) { }
        }

        override fun itemsRemovedAtIndexes(indexes: IntArray) {
            Log.d(TAG, "MediaQueue itemsRemovedAtIndexeseWillChange")
            super.itemsRemovedAtIndexes(indexes)

            val longIndexes = indexes.map { it.toLong() }
            flutterApi?.itemsRemovedAtIndexes(longIndexes) { }
        }
    }

    private inner class MyApi : PlatformBridgeApis.CastHostApi {
        override fun sendMessage(message: PlatformBridgeApis.CastMessage) {
            mMessageCastingChannel?.sendMessage(mCastSession, message)
        }

        override fun showCastDialog() {
            val context = applicationContext
            val activity = activity
            if (context == null || activity == null) {
                Log.d(TAG, "showCastDialog - missing context")
                return
            }

            CastDialogOpener.showCastDialog(context, activity)
        }

        override fun loadMediaLoadRequestData(request: PlatformBridgeApis.MediaLoadRequestData) {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return

            val mediaLoadRequest = getMediaLoadRequestData(request)
            remoteMediaClient.load(mediaLoadRequest)
        }

        override fun getMediaInfo(): PlatformBridgeApis.MediaInfo {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient
                    ?: throw IllegalStateException("Missing cast session")

            return getFlutterMediaInfo(remoteMediaClient.mediaInfo)
        }

        override fun play() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.play()
        }

        override fun pause() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.pause()
        }

        override fun stop() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.stop()
        }

        override fun showTracksChooserDialog() {
            if (activity !is FragmentActivity) {
                Log.e(TAG, "Error: no_fragment_activity, FlutterCastFramework requires activity to be a FragmentActivity.")
                return
            }

            val activity = activity as? FragmentActivity
            if (activity == null) {
                Log.d(TAG, "showTracksChooserDialog - missing context")
                return
            }

            TracksChooserDialogFragment.newInstance()
                    .show(activity.supportFragmentManager, "FlutterCastFrameworkTracksChooserDialog")
        }

        override fun skipAd() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.skipAd()
        }

        override fun seekTo(position: Long) {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.seek(MediaSeekOptions.Builder()
                    .setPosition(position)
                    .setResumeState(MediaSeekOptions.RESUME_STATE_UNCHANGED)
                    .build());
        }

        override fun queueAppendItem(item: PlatformBridgeApis.MediaQueueItem) {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return

            val mediaQueueItem = getMediaQueueItem(item) ?: return
            remoteMediaClient.queueAppendItem(mediaQueueItem, null)
        }

        override fun queueNextItem() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.queueNext(null)
        }

        override fun queuePrevItem() {
            val remoteMediaClient: RemoteMediaClient = remoteMediaClient ?: return
            remoteMediaClient.queuePrev(null)
        }

        override fun getQueueItemCount(): Long {
            return mediaQueue?.itemCount?.toLong() ?: -1
        }

        override fun getQueueItemAtIndex(index: Long): PlatformBridgeApis.MediaQueueItem {
            if (index < 0) return getFlutterMediaQueueItem(null)

            val mediaQueueItem = mediaQueue?.getItemAtIndex(index.toInt(), true)
            return getFlutterMediaQueueItem(mediaQueueItem)
        }

        override fun setMute(muted: Boolean) {
            val castSession = mCastSession ?: return
            castSession.isMute = muted
        }

        override fun getCastDevice(): PlatformBridgeApis.CastDevice {
            val castSession = mCastSession ?: throw IllegalStateException("Missing cast session")

            val castDevice = castSession.castDevice

            return PlatformBridgeApis.CastDevice().apply {
                deviceId = castDevice?.deviceId
                friendlyName = castDevice?.friendlyName
                modelName = castDevice?.modelName
            }
        }
    }

    private fun getOnNamespaceResult(oldSession: CastSession?, newSession: CastSession?) = PlatformBridgeApis.CastFlutterApi.Reply<MutableList<String>> { namespaces ->
        Log.d(TAG, "Updating mCastSession - getOnNamespaceResult - param: $namespaces")
        if (oldSession == null && newSession == null) return@Reply // nothing to do here
        if (namespaces == null || !namespaces.any()) return@Reply  // nothing to do here

        namespaces.forEach { namespace ->
            try {
                oldSession?.removeMessageReceivedCallbacks(namespace)
                if (mMessageCastingChannel != null) newSession?.setMessageReceivedCallbacks(namespace, mMessageCastingChannel!!)
            } catch (e: java.lang.Exception) {
                Log.e(TAG, "Updating mCastSession - Exception while creating channel", e)
            }
        }
    }

    private inner class CastSessionManagerListener : SessionManagerListener<CastSession> {
        private var TAG = "SessionManagerListenerImpl"

        override fun onSessionSuspended(session: CastSession, p1: Int) {
            Log.d(TAG, "onSessionSuspended")
            flutterApi?.onSessionSuspended { }
        }

        override fun onSessionStarting(session: CastSession) {
            Log.d(TAG, "onSessionStarting")
            flutterApi?.onSessionStarting { }

            mCastSession = session
        }

        override fun onSessionResuming(session: CastSession, p1: String) {
            Log.d(TAG, "onSessionResuming")
            flutterApi?.onSessionResuming { }

            mCastSession = session
        }

        override fun onSessionEnding(session: CastSession) {
            Log.d(TAG, "onSessionEnding")
            flutterApi?.onSessionEnding { }
        }

        override fun onSessionStartFailed(session: CastSession, p1: Int) {
            Log.d(TAG, "onSessionStartFailed")
            flutterApi?.onSessionStartFailed { }
        }

        override fun onSessionResumeFailed(session: CastSession, p1: Int) {
            Log.d(TAG, "onSessionResumeFailed")
            flutterApi?.onSessionResumeFailed { }
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            Log.d(TAG, "onSessionStarted")
            flutterApi?.onSessionStarted { }

            mCastSession = session
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            Log.d(TAG, "onSessionResumed")
            flutterApi?.onSessionResumed { }

            mCastSession = session
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            Log.d(TAG, "onSessionEnded")
            flutterApi?.onSessionEnded { }
        }
    }
}
