import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/study_channel.dart';

/// Repository managing persistence of whitelisted educational YouTube channels in SQLite.
class StudyChannelsRepository {
  final AppDatabase appDatabase;

  StudyChannelsRepository({required this.appDatabase});

  Future<Database> get _db => appDatabase.database;

  Future<List<StudyChannel>> getChannels() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.studyChannels,
      orderBy: '${DatabaseTables.colChannelAddedAt} DESC',
    );
    if (rows.isEmpty) {
      await seedDefaults(db);
      final seeded = await db.query(
        DatabaseTables.studyChannels,
        orderBy: '${DatabaseTables.colChannelAddedAt} DESC',
      );
      return seeded.map((r) => StudyChannel.fromMap(r)).toList();
    }
    return rows.map((r) => StudyChannel.fromMap(r)).toList();
  }

  Future<int> getChannelCount() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.studyChannels}'),
    );
    return count ?? 0;
  }

  Future<void> addChannel(StudyChannel channel) async {
    final db = await _db;
    await db.insert(
      DatabaseTables.studyChannels,
      channel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteChannel(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseTables.studyChannels,
      where: '${DatabaseTables.colChannelId} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isWhitelisted(String query) async {
    final channels = await getChannels();
    final cleanQuery = query.toLowerCase().replaceAll('@', '').trim();
    for (final ch in channels) {
      final name = ch.channelName.toLowerCase().trim();
      final url = (ch.channelUrl ?? '').toLowerCase().replaceAll('@', '').trim();
      if (cleanQuery.contains(name) || name.contains(cleanQuery)) return true;
      if (url.isNotEmpty && (cleanQuery.contains(url) || url.contains(cleanQuery))) return true;
    }
    return false;
  }

  Future<void> seedDefaults(Database db) async {
    final now = DateTime.now();
    final defaults = [
      StudyChannel(
        id: 'seed-3blue1brown',
        channelName: '3Blue1Brown',
        channelUrl: '@3blue1brown',
        addedAt: now.subtract(const Duration(days: 3)),
      ),
      StudyChannel(
        id: 'seed-khan-academy',
        channelName: 'Khan Academy',
        channelUrl: '@khanacademy',
        addedAt: now.subtract(const Duration(days: 2)),
      ),
      StudyChannel(
        id: 'seed-mit-ocw',
        channelName: 'MIT OpenCourseWare',
        channelUrl: '@mitocw',
        addedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final ch in defaults) {
      await db.insert(
        DatabaseTables.studyChannels,
        ch.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
