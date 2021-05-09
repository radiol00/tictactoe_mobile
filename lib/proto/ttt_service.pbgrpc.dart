///
//  Generated code. Do not modify.
//  source: ttt_service.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'ttt_service.pb.dart' as $0;
export 'ttt_service.pb.dart';

class TTTClient extends $grpc.Client {
  static final _$joinMatchmaking = $grpc.ClientMethod<$0.User, $0.Game>(
      '/protos.TTT/JoinMatchmaking',
      ($0.User value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Game.fromBuffer(value));

  TTTClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.Game> joinMatchmaking($0.User request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$joinMatchmaking, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class TTTServiceBase extends $grpc.Service {
  $core.String get $name => 'protos.TTT';

  TTTServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.User, $0.Game>(
        'JoinMatchmaking',
        joinMatchmaking_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.User.fromBuffer(value),
        ($0.Game value) => value.writeToBuffer()));
  }

  $async.Stream<$0.Game> joinMatchmaking_Pre(
      $grpc.ServiceCall call, $async.Future<$0.User> request) async* {
    yield* joinMatchmaking(call, await request);
  }

  $async.Stream<$0.Game> joinMatchmaking(
      $grpc.ServiceCall call, $0.User request);
}
