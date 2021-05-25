///
//  Generated code. Do not modify.
//  source: ttt_service.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use userDescriptor instead')
const User$json = const {
  '1': 'User',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode('CgRVc2VyEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use gameDescriptor instead')
const Game$json = const {
  '1': 'Game',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `Game`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameDescriptor = $convert.base64Decode('CgRHYW1lEg4KAmlkGAEgASgJUgJpZA==');
@$core.Deprecated('Use handShakeDescriptor instead')
const HandShake$json = const {
  '1': 'HandShake',
};

/// Descriptor for `HandShake`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handShakeDescriptor = $convert.base64Decode('CglIYW5kU2hha2U=');
@$core.Deprecated('Use responseDescriptor instead')
const Response$json = const {
  '1': 'Response',
  '2': const [
    const {'1': 'game_id', '3': 1, '4': 1, '5': 11, '6': '.protos.Game', '9': 0, '10': 'gameId'},
    const {'1': 'handshake', '3': 2, '4': 1, '5': 11, '6': '.protos.HandShake', '9': 0, '10': 'handshake'},
  ],
  '8': const [
    const {'1': 'data'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode('CghSZXNwb25zZRInCgdnYW1lX2lkGAEgASgLMgwucHJvdG9zLkdhbWVIAFIGZ2FtZUlkEjEKCWhhbmRzaGFrZRgCIAEoCzIRLnByb3Rvcy5IYW5kU2hha2VIAFIJaGFuZHNoYWtlQgYKBGRhdGE=');
@$core.Deprecated('Use statusDescriptor instead')
const Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'stat', '3': 1, '4': 1, '5': 5, '10': 'stat'},
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode('CgZTdGF0dXMSEgoEc3RhdBgBIAEoBVIEc3RhdA==');
@$core.Deprecated('Use finalGameDescriptor instead')
const FinalGame$json = const {
  '1': 'FinalGame',
  '2': const [
    const {'1': 'game_id', '3': 1, '4': 1, '5': 9, '10': 'gameId'},
    const {'1': 'uid', '3': 2, '4': 1, '5': 9, '10': 'uid'},
  ],
};

/// Descriptor for `FinalGame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finalGameDescriptor = $convert.base64Decode('CglGaW5hbEdhbWUSFwoHZ2FtZV9pZBgBIAEoCVIGZ2FtZUlkEhAKA3VpZBgCIAEoCVIDdWlk');
