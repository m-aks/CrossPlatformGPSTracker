import 'dart:async';
import 'dart:io';

import 'package:ios_android_flutter/sqlite/route.dart';
import 'package:ios_android_flutter/sqlite/track.dart';
import 'package:ios_android_flutter/sqlite/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider db = DBProvider._();

  DBProvider._();

  static int? userId;
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return await openDatabase(join(documentsDirectory.path, "database"),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS users ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "login TEXT,"
          "token TEXT,"
          "active BOOLEAN)");
      await db.execute("CREATE TABLE IF NOT EXISTS tracks ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "date INTEGER,"
          "distance INTEGER,"
          "average_speed REAL,"
          "time INTEGER,"
          "user_id INTEGER,"
          "CONSTRAINT fk_users FOREIGN KEY (user_id) "
          "REFERENCES users(id))");
      await db.execute("CREATE TABLE IF NOT EXISTS routes ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "latitude REAL,"
          "longitude REAL,"
          "track_id INTEGER,"
          "CONSTRAINT fk_tracks FOREIGN KEY (track_id) "
          "REFERENCES tracks(id))");
    });
  }

  newUser(User user) async {
    final db = await database;
    var raw = await db?.rawInsert(
        "INSERT INTO users (login, token, active) "
        "VALUES (?, ?, ?)",
        [user.login, user.token, user.active]);
    return raw;
  }

  updateUser(User user) async {
    final db = await database;
    var raw = await db?.rawUpdate(
        "UPDATE users "
        "SET login = ?, token = ?, active = ? "
        "WHERE id = ?",
        [user.login, user.token, user.active, user.id]);
    return raw;
  }

  Future<User?> getUserByLogin(String login) async {
    final db = await database;
    var res = await db?.rawQuery(
        "SELECT * FROM users WHERE login = ? ORDER BY id DESC LIMIT 1",
        [login]);
    User? user = res != null && res.isNotEmpty ? User.fromMap(res[0]) : null;
    return user;
  }

  Future<User?> getActiveUser() async {
    final db = await database;
    var res = await db?.rawQuery(
        "SELECT * FROM users WHERE active = 1 ORDER BY id DESC LIMIT 1");
    User? user = res != null && res.isNotEmpty ? User.fromMap(res[0]) : null;
    return user;
  }

  newTrack(Track track) async {
    final db = await database;
    var raw = await db?.rawInsert(
        "INSERT INTO tracks (date, distance, average_speed, time, user_id) "
        "VALUES (?, ?, ?, ?, ?)",
        [
          track.date,
          track.distance,
          track.averageSpeed,
          track.time,
          track.userId
        ]);
    return raw;
  }

  Future<List<Track>> getTracks() async {
    if (userId != null) {
      final db = await database;
      var res = await db?.rawQuery(
          "SELECT * FROM tracks WHERE user_id = ? ORDER BY date DESC",
          [userId]);
      List<Track>? list = res != null && res.isNotEmpty
          ? res.map((c) => Track.fromMap(c)).toList()
          : [];
      return list;
    } else {
      return [];
    }
  }

  Future<Track?> getLastTrack() async {
    if (userId != null) {
      final db = await database;
      var res = await db?.rawQuery(
          "SELECT * FROM tracking WHERE user_id = ? ORDER BY id DESC LIMIT 1",
          [userId]);
      Track? track =
          res != null && res.isNotEmpty ? Track.fromMap(res[0]) : null;
      return track;
    } else {
      return null;
    }
  }

  Future<Track?> getTrackByDate(DateTime date) async {
    final db = await database;
    var res = await db?.rawQuery(
        "SELECT * FROM tracks WHERE date = ? and user_id = ?", [date, userId]);
    Track? track = res != null && res.isNotEmpty ? Track.fromMap(res[0]) : null;
    return track;
  }

  newRoute(Rout route) async {
    final db = await database;
    var raw = await db?.rawInsert(
        "INSERT INTO routes (latitude, longitude, track_id) "
        "VALUES (?, ?, ?)",
        [route.latitude, route.longitude, route.trackId]);
    return raw;
  }

  Future<List<Rout>> getRoutesByTrackId(int id) async {
    final db = await database;
    var res =
        await db?.rawQuery("SELECT * FROM routes WHERE track_id = ?", [id]);
    List<Rout> routes = res != null && res.isNotEmpty
        ? res.map((res) => Rout.fromMap(res)).toList()
        : [];
    return routes;
  }
}
