import '../../../core/database/database_tables.dart';

/// Domain model representing a whitelisted educational YouTube channel.
class StudyChannel {
  final String id;
  final String channelName;
  final String? channelUrl;
  final DateTime addedAt;

  const StudyChannel({
    required this.id,
    required this.channelName,
    this.channelUrl,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colChannelId: id,
      DatabaseTables.colChannelName: channelName,
      DatabaseTables.colChannelUrl: channelUrl,
      DatabaseTables.colChannelAddedAt: addedAt.millisecondsSinceEpoch,
    };
  }

  factory StudyChannel.fromMap(Map<String, dynamic> map) {
    return StudyChannel(
      id: map[DatabaseTables.colChannelId] as String,
      channelName: map[DatabaseTables.colChannelName] as String,
      channelUrl: map[DatabaseTables.colChannelUrl] as String?,
      addedAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseTables.colChannelAddedAt] as int,
      ),
    );
  }
}
