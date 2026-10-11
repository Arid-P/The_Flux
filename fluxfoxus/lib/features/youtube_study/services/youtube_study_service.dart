import 'dart:async';
import '../data/study_channels_repository.dart';
import '../domain/confirmation_sentences.dart';
import '../domain/study_channel.dart';

/// Service coordinating YouTube Study Mode enforcement per GMP_FF_BUILD.md Step 15 & 16.
class YouTubeStudyService {
  final StudyChannelsRepository repository;
  bool _isStudyModeActive = false;
  String? _lastSentence;

  final _blockedChannelEvents = StreamController<String>.broadcast();

  YouTubeStudyService({required this.repository});

  bool get isStudyModeActive => _isStudyModeActive;
  Stream<String> get blockedChannelStream => _blockedChannelEvents.stream;

  void setStudyModeActive(bool active) {
    _isStudyModeActive = active;
  }

  /// Gets the next confirmation sentence based on current channel count,
  /// guaranteeing no two identical sentences consecutively.
  Future<String> getNextConfirmationSentence() async {
    final count = await repository.getChannelCount();
    final sentence = ConfirmationSentences.getRandomSentence(
      currentChannelCount: count,
      lastSentence: _lastSentence,
    );
    _lastSentence = sentence;
    return sentence;
  }

  /// Evaluates whether a YouTube channel or video title is permitted during study mode.
  Future<bool> isAllowed(String channelOrVideoTitle) async {
    if (!_isStudyModeActive) return true;
    final allowed = await repository.isWhitelisted(channelOrVideoTitle);
    if (!allowed) {
      _blockedChannelEvents.add(channelOrVideoTitle);
    }
    return allowed;
  }

  Future<void> addWhitelistedChannel(StudyChannel channel) async {
    await repository.addChannel(channel);
  }

  Future<void> removeWhitelistedChannel(String channelId) async {
    await repository.deleteChannel(channelId);
  }

  Future<List<StudyChannel>> getWhitelistedChannels() async {
    return repository.getChannels();
  }

  void dispose() {
    _blockedChannelEvents.close();
  }
}
