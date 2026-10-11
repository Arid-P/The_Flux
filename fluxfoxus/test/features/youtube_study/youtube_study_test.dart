import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/features/youtube_study/youtube_study.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ConfirmationSentences Tests', () {
    test('shortPool has exactly 5 sentences and longPool has 50 sentences', () {
      expect(ConfirmationSentences.shortPool.length, 5);
      expect(ConfirmationSentences.longPool.length, 50);
    });

    test('getRandomSentence picks from shortPool when channels <= 25', () {
      final sentence = ConfirmationSentences.getRandomSentence(currentChannelCount: 10);
      expect(ConfirmationSentences.shortPool.contains(sentence), true);
    });

    test('getRandomSentence picks from longPool when channels > 25', () {
      final sentence = ConfirmationSentences.getRandomSentence(currentChannelCount: 26);
      expect(ConfirmationSentences.longPool.contains(sentence), true);
    });

    test('getRandomSentence avoids repeating the same sentence twice consecutively', () {
      final first = ConfirmationSentences.getRandomSentence(currentChannelCount: 5);
      for (int i = 0; i < 20; i++) {
        final next = ConfirmationSentences.getRandomSentence(
          currentChannelCount: 5,
          lastSentence: first,
        );
        expect(next, isNot(equals(first)));
      }
    });
  });

  group('StudyChannelsRepository & YouTubeStudyService Tests', () {
    late AppDatabase appDatabase;
    late StudyChannelsRepository repository;
    late YouTubeStudyService service;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      repository = StudyChannelsRepository(appDatabase: appDatabase);
      service = YouTubeStudyService(repository: repository);
    });

    tearDown(() async {
      service.dispose();
      await appDatabase.close();
    });

    test('getChannels seeds default educational channels', () async {
      final channels = await repository.getChannels();
      expect(channels.length, 3);
      expect(channels.any((c) => c.channelName == '3Blue1Brown'), true);
      expect(channels.any((c) => c.channelName == 'Khan Academy'), true);
      expect(channels.any((c) => c.channelName == 'MIT OpenCourseWare'), true);
    });

    test('isWhitelisted returns true for whitelisted names/handles and false for non-whitelisted', () async {
      expect(await repository.isWhitelisted('3Blue1Brown - Linear Algebra'), true);
      expect(await repository.isWhitelisted('@khanacademy'), true);
      expect(await repository.isWhitelisted('Random Gaming Streamer'), false);
    });

    test('isAllowed in YouTubeStudyService blocks non-whitelisted channels only when active', () async {
      service.setStudyModeActive(false);
      expect(await service.isAllowed('Random Entertainment Video'), true);

      service.setStudyModeActive(true);
      expect(await service.isAllowed('3Blue1Brown Chapter 2'), true);

      bool blockedEventEmitted = false;
      final sub = service.blockedChannelStream.listen((_) {
        blockedEventEmitted = true;
      });

      final allowed = await service.isAllowed('Frivolous Prank Show');
      await Future<void>.delayed(Duration.zero);
      expect(allowed, false);
      expect(blockedEventEmitted, true);
      await sub.cancel();
    });

    test('addChannel and deleteChannel correctly persist and remove entries', () async {
      final newCh = StudyChannel(
        id: 'cs50-channel',
        channelName: 'CS50',
        channelUrl: '@cs50',
        addedAt: DateTime.now(),
      );

      await repository.addChannel(newCh);
      expect(await repository.isWhitelisted('CS50 Week 0 Lecture'), true);

      await repository.deleteChannel('cs50-channel');
      expect(await repository.isWhitelisted('CS50 Week 0 Lecture'), false);
    });
  });
}
