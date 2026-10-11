import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/features/youtube_study/youtube_study.dart';
import 'package:fluxfoxus/presentation/screens/channel_whitelist_screen.dart';

class _FakeStudyChannelsRepository extends StudyChannelsRepository {
  List<StudyChannel> channels;

  _FakeStudyChannelsRepository(this.channels) : super(appDatabase: AppDatabase());

  @override
  Future<List<StudyChannel>> getChannels() async => List.from(channels);

  @override
  Future<int> getChannelCount() async => channels.length;

  @override
  Future<void> addChannel(StudyChannel channel) async {
    channels.add(channel);
  }

  @override
  Future<void> deleteChannel(String id) async {
    channels.removeWhere((c) => c.id == id);
  }

  @override
  Future<bool> isWhitelisted(String query) async {
    return channels.any((c) =>
        query.toLowerCase().contains(c.channelName.toLowerCase()) ||
        c.channelName.toLowerCase().contains(query.toLowerCase()));
  }
}

void main() {
  group('YouTube Study Widget Tests', () {
    late _FakeStudyChannelsRepository fakeRepository;

    setUp(() {
      final now = DateTime.now();
      fakeRepository = _FakeStudyChannelsRepository([
        StudyChannel(
          id: '1',
          channelName: '3Blue1Brown',
          channelUrl: '@3blue1brown',
          addedAt: now,
        ),
        StudyChannel(
          id: '2',
          channelName: 'Khan Academy',
          channelUrl: '@khanacademy',
          addedAt: now,
        ),
      ]);
    });

    testWidgets('YouTubeStudyEdgeGrabber expands and toggles study mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyChannelsRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: YouTubeStudyEdgeGrabber(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('youtube_grabber_pill')), findsOneWidget);

      await tester.tap(find.byKey(const Key('youtube_grabber_pill')));
      await tester.pumpAndSettle();

      expect(find.text('YouTube Study'), findsOneWidget);
      expect(find.byKey(const Key('youtube_study_mode_switch')), findsOneWidget);

      await tester.tap(find.byKey(const Key('youtube_study_mode_switch')));
      await tester.pumpAndSettle();

      expect(find.text('Enforcing Whitelist'), findsOneWidget);
    });

    testWidgets('AddChannelConfirmationSheet disables button until exact sentence is typed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyChannelsRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddChannelConfirmationSheet(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Enter channel name
      await tester.enterText(find.byKey(const Key('channel_name_input')), 'Numberphile');
      await tester.pump();

      // Button is still disabled because sentence hasn't been typed
      final buttonFinder = find.byKey(const Key('confirm_add_channel_button'));
      final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(elevatedButton.onPressed, isNull);

      // Find the required sentence text
      final targetWidget = tester.widget<SelectableText>(find.byKey(const Key('confirmation_sentence_target')));
      final targetSentence = targetWidget.data!;

      // Enter incorrect sentence
      await tester.enterText(find.byKey(const Key('confirmation_sentence_input')), 'Wrong sentence');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

      // Enter the EXACT sentence
      await tester.enterText(find.byKey(const Key('confirmation_sentence_input')), targetSentence);
      await tester.pump();

      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNotNull);
    });

    testWidgets('ChannelWhitelistScreen renders list and search filters channels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyChannelsRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ChannelWhitelistScreen(presetId: 'default'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('YouTube Study Mode'), findsOneWidget);
      expect(find.text('3Blue1Brown'), findsOneWidget);
      expect(find.text('Khan Academy'), findsOneWidget);

      // Filter by "Khan"
      await tester.enterText(find.byKey(const Key('channel_search_bar')), 'Khan');
      await tester.pump();

      expect(find.text('Khan Academy'), findsOneWidget);
      expect(find.text('3Blue1Brown'), findsNothing);
    });
  });
}
