import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/blocking/services/app_detection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelAppDetectionService Tests', () {
    const channel = MethodChannel('com.fluxfoxus/accessibility_service');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        log.add(call);
        switch (call.method) {
          case 'isAccessibilityServiceEnabled':
            return true;
          case 'setSessionActive':
          case 'updateBlockedPackages':
          case 'redirectToApp':
            return true;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('isAccessibilityServiceEnabled queries platform channel', () async {
      final service = MethodChannelAppDetectionService(channel: channel);
      final isEnabled = await service.isAccessibilityServiceEnabled();

      expect(isEnabled, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, equals('isAccessibilityServiceEnabled'));
      service.dispose();
    });

    test('setSessionActive invokes platform channel with argument', () async {
      final service = MethodChannelAppDetectionService(channel: channel);
      await service.setSessionActive(true);

      expect(log, hasLength(1));
      expect(log.first.method, equals('setSessionActive'));
      expect(log.first.arguments, equals({'isActive': true}));

      await service.setSessionActive(false);
      expect(log, hasLength(2));
      expect(log.last.arguments, equals({'isActive': false}));
      service.dispose();
    });

    test('updateBlockedPackages invokes platform channel with packages list', () async {
      final service = MethodChannelAppDetectionService(channel: channel);
      final packages = ['com.instagram.android', 'tv.twitch.android'];
      await service.updateBlockedPackages(packages);

      expect(log, hasLength(1));
      expect(log.first.method, equals('updateBlockedPackages'));
      expect(log.first.arguments, equals({'packages': packages}));
      service.dispose();
    });

    test('redirectToApp invokes platform channel with target package', () async {
      final service = MethodChannelAppDetectionService(channel: channel);
      await service.redirectToApp('com.fluxfoxus.fluxfoxus');

      expect(log, hasLength(1));
      expect(log.first.method, equals('redirectToApp'));
      expect(log.first.arguments, equals({'packageName': 'com.fluxfoxus.fluxfoxus'}));
      service.dispose();
    });

    test('handles incoming onAppChanged from native platform', () async {
      final service = MethodChannelAppDetectionService(channel: channel);
      final received = <String>[];
      final sub = service.foregroundAppStream.listen(received.add);

      // Simulate native platform sending onAppChanged
      final binaryMessenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final codec = const StandardMethodCodec();
      final callData = codec.encodeMethodCall(
        const MethodCall('onAppChanged', {'packageName': 'com.instagram.android'}),
      );

      await binaryMessenger.handlePlatformMessage(
        'com.fluxfoxus/accessibility_service',
        callData,
        (data) {},
      );

      await pumpEventQueue();

      expect(received, equals(['com.instagram.android']));
      await sub.cancel();
      service.dispose();
    });
  });

  group('FakeAppDetectionService Tests', () {
    test('tracks session active, blocked packages, and emit events', () async {
      final fake = FakeAppDetectionService();
      final events = <String>[];
      final sub = fake.foregroundAppStream.listen(events.add);

      expect(await fake.isAccessibilityServiceEnabled(), isTrue);

      await fake.setSessionActive(true);
      expect(fake.isSessionActive, isTrue);

      await fake.updateBlockedPackages(['com.reddit.frontpage']);
      expect(fake.blockedPackages, equals(['com.reddit.frontpage']));

      fake.emitForegroundApp('com.reddit.frontpage');
      await pumpEventQueue();
      expect(events, equals(['com.reddit.frontpage']));

      await fake.redirectToApp('com.fluxfoxus');
      expect(fake.redirectCount, equals(1));
      expect(fake.redirectCalls, equals(['com.fluxfoxus']));

      await sub.cancel();
      fake.dispose();
    });
  });
}
