import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with WidgetsBindingObserver {
  final _connectivity = Connectivity();
  late final StreamSubscription _connectivityStream;
  // false - disconnected, true - connected
  bool _lastConnState = false;
  final _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  ConnectivityService() {
    _connectivityController.onListen = _replayLastState;
    _connectivityStream =
        _connectivity.onConnectivityChanged.listen(_updateStream);
  }

  void _updateStream(List<ConnectivityResult> result) {
    final connectivities = [
      ConnectivityResult.ethernet,
      ConnectivityResult.mobile,
      ConnectivityResult.wifi
    ];
    if (result.any((conn) => connectivities.contains(conn))) {
      // there's some issue with the connectivity_plus package,
      // that it sends changes twice, try to mitigate that
      if (!_lastConnState) {
        _lastConnState = true;
        _connectivityController.add(true);
      }
    } else {
      if (_lastConnState) {
        _lastConnState = false;
        _connectivityController.add(false);
      }
    }
  }

  void _replayLastState() {
    _connectivityController.add(_lastConnState);
  }

  void dispose() {
    _connectivityController.close();
    _connectivityStream.cancel();
  }

  // as per connectivity_plus recommendation,
  // force update the connectivity stream once app re-enters foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivity.checkConnectivity().then((result) => _updateStream(result));
    }
    super.didChangeAppLifecycleState(state);
  }
}
