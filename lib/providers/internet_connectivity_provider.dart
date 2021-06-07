import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final internetConnectivityController = StateNotifierProvider.autoDispose<
    InternetConnectivityNotifier,
    AsyncValue<ConnectivityResult>>((ref) => InternetConnectivityNotifier());

class InternetConnectivityNotifier
    extends StateNotifier<AsyncValue<ConnectivityResult>> {
  StreamSubscription _connectivitySubscription;
  InternetConnectivityNotifier() : super(AsyncValue.loading()) {
    init();
  }

  void init() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    state = AsyncValue.data(connectivityResult);

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult conn) {
      state = AsyncValue.data(conn);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
}
