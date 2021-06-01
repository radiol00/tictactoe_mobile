import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:wand_tictactoe/proto/ttt_service.pbgrpc.dart' as proto;
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

final grpcProvider =
    Provider<WANDgRPCConnection>((ref) => WANDgRPCConnection(ref));

class WANDgRPCConnection {
  ClientChannel _channel;
  proto.TTTClient _client;
  ProviderReference _ref;
  ResponseStream _stream;
  bool _listening = false;
  String _host = "192.168.0.103";
  int _port = 9999;

  WANDgRPCConnection(ref) {
    _ref = ref;
    _channel = ClientChannel(
      _host,
      port: _port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
  }

  void dial() async {
    _channel = ClientChannel(
      _host,
      port: _port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _client = proto.TTTClient(_channel);
  }

  Stream<proto.Response> joinMatchmaking() {
    if (_listening) return null;
    var tttuser = _ref.read(firebaseAuthController).data.value;
    if (tttuser == null) return null;
    _stream = _client.joinMatchmaking(
      proto.User(
        id: tttuser.firebaseUserObject.uid,
        name: tttuser.firebaseUserObject.displayName,
      ),
    );
    _listening = true;
    return _stream.asBroadcastStream();
  }

  void leaveMatchmaking() {
    if (!_listening) return;
    _stream.cancel();
    _listening = false;
  }

  bool get listening => _listening;
}
