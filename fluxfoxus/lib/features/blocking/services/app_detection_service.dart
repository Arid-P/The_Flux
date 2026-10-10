import 'dart:async';
import 'package:flutter/services.dart';

/// Abstraction for device foreground app detection and redirection per TRD §5.2.
abstract class AppDetectionService {
  /// Stream of package names transitioning to the foreground.
  Stream<String> get foregroundAppStream;

  /// Checks if the accessibility service is granted and enabled in Android settings.
  Future<bool> isAccessibilityServiceEnabled();

  /// Informs native service whether a focus session is currently running.
  Future<void> setSessionActive(bool isActive);

  /// Updates the list of package names that are blocked during active sessions.
  Future<void> updateBlockedPackages(List<String> packages);

  /// Triggers a redirect to bring FluxFoxus (or a specified target) to the foreground.
  Future<void> redirectToApp([String? packageName]);

  /// Disposes any stream resources.
  void dispose();
}

/// Production implementation using Android MethodChannel.
class MethodChannelAppDetectionService implements AppDetectionService {
  static const MethodChannel defaultChannel = MethodChannel('com.fluxfoxus/accessibility_service');

  final MethodChannel _channel;
  final StreamController<String> _controller = StreamController<String>.broadcast();

  MethodChannelAppDetectionService({MethodChannel? channel})
      : _channel = channel ?? defaultChannel {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onAppChanged') {
      final args = call.arguments as Map<dynamic, dynamic>?;
      final packageName = args?['packageName'] as String?;
      if (packageName != null && packageName.isNotEmpty) {
        _controller.add(packageName);
      }
    }
    return null;
  }

  @override
  Stream<String> get foregroundAppStream => _controller.stream;

  @override
  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> setSessionActive(bool isActive) async {
    try {
      await _channel.invokeMethod('setSessionActive', {'isActive': isActive});
    } on PlatformException {
      // Ignored on platforms where method is unsupported
    }
  }

  @override
  Future<void> updateBlockedPackages(List<String> packages) async {
    try {
      await _channel.invokeMethod('updateBlockedPackages', {'packages': packages});
    } on PlatformException {
      // Ignored on platforms where method is unsupported
    }
  }

  @override
  Future<void> redirectToApp([String? packageName]) async {
    try {
      await _channel.invokeMethod('redirectToApp', {'packageName': packageName});
    } on PlatformException {
      // Ignored on platforms where method is unsupported
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// In-memory fake implementation for hermetic testing and preview modes.
class FakeAppDetectionService implements AppDetectionService {
  final StreamController<String> _controller = StreamController<String>.broadcast();

  bool isServiceEnabled = true;
  bool isSessionActive = false;
  List<String> blockedPackages = [];
  final List<String?> redirectCalls = [];

  int get redirectCount => redirectCalls.length;

  void emitForegroundApp(String packageName) {
    _controller.add(packageName);
  }

  @override
  Stream<String> get foregroundAppStream => _controller.stream;

  @override
  Future<bool> isAccessibilityServiceEnabled() async => isServiceEnabled;

  @override
  Future<void> setSessionActive(bool isActive) async {
    isSessionActive = isActive;
  }

  @override
  Future<void> updateBlockedPackages(List<String> packages) async {
    blockedPackages = List.from(packages);
  }

  @override
  Future<void> redirectToApp([String? packageName]) async {
    redirectCalls.add(packageName);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
