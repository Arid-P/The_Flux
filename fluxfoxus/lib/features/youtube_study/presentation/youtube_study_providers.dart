import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presets/presets.dart';
import '../data/study_channels_repository.dart';
import '../domain/study_channel.dart';
import '../services/youtube_study_service.dart';

final studyChannelsRepositoryProvider = Provider<StudyChannelsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StudyChannelsRepository(appDatabase: db);
});

final youtubeStudyServiceProvider = Provider<YouTubeStudyService>((ref) {
  final repo = ref.watch(studyChannelsRepositoryProvider);
  final service = YouTubeStudyService(repository: repo);
  ref.onDispose(service.dispose);
  return service;
});

class YouTubeStudyActiveNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(youtubeStudyServiceProvider);
    return service.isStudyModeActive;
  }

  void toggle() {
    final service = ref.read(youtubeStudyServiceProvider);
    final newState = !state;
    service.setStudyModeActive(newState);
    state = newState;
  }

  void set(bool active) {
    final service = ref.read(youtubeStudyServiceProvider);
    service.setStudyModeActive(active);
    state = active;
  }
}

final youtubeStudyActiveProvider =
    NotifierProvider<YouTubeStudyActiveNotifier, bool>(
  YouTubeStudyActiveNotifier.new,
);

class WhitelistedChannelsNotifier extends AsyncNotifier<List<StudyChannel>> {
  @override
  Future<List<StudyChannel>> build() async {
    final repo = ref.watch(studyChannelsRepositoryProvider);
    return repo.getChannels();
  }

  Future<void> addChannel(StudyChannel channel) async {
    final repo = ref.read(studyChannelsRepositoryProvider);
    await repo.addChannel(channel);
    ref.invalidateSelf();
  }

  Future<void> removeChannel(String id) async {
    final repo = ref.read(studyChannelsRepositoryProvider);
    await repo.deleteChannel(id);
    ref.invalidateSelf();
  }
}

final whitelistedChannelsProvider =
    AsyncNotifierProvider<WhitelistedChannelsNotifier, List<StudyChannel>>(
  WhitelistedChannelsNotifier.new,
);
