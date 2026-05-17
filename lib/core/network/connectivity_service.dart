import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service that monitors network connectivity and exposes a reactive stream.
class ConnectivityService {
  ConnectivityService._();
  static final instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Initialize and start listening to connectivity changes.
  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);
    if (kDebugMode) {
      debugPrint(
        '[Connectivity] Initial state: ${_isOnline ? "ONLINE" : "OFFLINE"}',
      );
    }

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final newState = _hasConnection(results);
      if (newState != _isOnline) {
        _isOnline = newState;
        _controller.add(_isOnline);
        if (kDebugMode) {
          debugPrint(
            '[Connectivity] Changed to: ${_isOnline ? "ONLINE" : "OFFLINE"}',
          );
        }
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
