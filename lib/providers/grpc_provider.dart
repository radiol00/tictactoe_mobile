import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:wand_tictactoe/proto/ttt_service.pbgrpc.dart' as proto;
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

final grpcProvider =
    Provider<WANDgRPCConnection>((ref) => WANDgRPCConnection(ref));

class WANDgRPCConnection {
  ClientChannel _channel;
  proto.TTTClient _client;
  bool _connected = false;
  ProviderReference _ref;
  ResponseStream _stream;
  bool _listening = false;

  WANDgRPCConnection(ref) {
    _channel = ClientChannel(
      "192.168.0.100",
      port: 9999,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _ref = ref;
  }

  void dial() {
    _client = proto.TTTClient(_channel);
    _connected = true;
  }

  ResponseStream<proto.Game> joinMatchmaking() {
    if (_listening) return null;
    var tttuser = _ref.read(firebaseAuthController.state).data.value;
    if (tttuser == null) return null;
    _stream = _client.joinMatchmaking(
      proto.User(
          id: tttuser.firebaseUserObject.uid,
          name: tttuser.firebaseUserObject.displayName),
    );
    _listening = true;
    return _stream;
  }

  void leaveMatchmaking() {
    if (!_listening) return;
    _stream.cancel();
    _listening = false;
  }

  bool get connected => _connected;
  bool get listening => _listening;
}
