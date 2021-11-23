import '../PlatformBridgeApis.dart';

class RemoteMediaClient {
  final CastHostApi _hostApi;

  RemoteMediaClient(this._hostApi);

  void load(MediaLoadRequestData request) {
    _hostApi.loadMediaLoadRequestData(request);
  }

  Future<MediaInfo> getMediaInfo() async {
    return await _hostApi.getMediaInfo();
  }
}
