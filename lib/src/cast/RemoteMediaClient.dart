import '../PlatformBridgeApis.dart';

typedef ProgressListener = void Function(int progressMs, int durationMs);

class RemoteMediaClient {
  final CastHostApi _hostApi;

  ProgressListener? onProgressUpdated;

  RemoteMediaClient(this._hostApi);

  void load(MediaLoadRequestData request) {
    _hostApi.loadMediaLoadRequestData(request);
  }

  void play() {
    _hostApi.play();
  }

  void pause() {
    _hostApi.pause();
  }

  void stop() {
    _hostApi.stop();
  }

  Future<MediaInfo> getMediaInfo() async {
    return await _hostApi.getMediaInfo();
  }
}
