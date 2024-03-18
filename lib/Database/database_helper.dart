import 'package:elzsi/Models/user_model.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  Future<Database> getDatabase() async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, 'userinfo.db');
    final appDb = await sql.openDatabase(
      dbPath,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE user_info (id INTEGER PRIMARY KEY, userid TEXT, deviceid TEXT, usertoken TEXT, fcmtoken TEXT);');
      },
      version: 1,
    );
    return appDb;
  }

  Future<UserModel> initDb() async {
    final appDb = await DatabaseHelper().getDatabase();
    final table = await appDb.query('user_info');
    final userInfo = table
        .map((row) => UserModel(
            userId: int.parse(row['userid'] as String),
            deviceId: row['deviceid'] as String,
            token: row['usertoken'] as String,
            fcmToken: row['fcmtoken'] as String))
        .toList();
    return userInfo.isNotEmpty
        ? userInfo[0]
        : const UserModel(userId: 0, token: '', fcmToken: '', deviceId: '');
  }

  Future<void> insertDb(UserModel userInfo) async {
    final Database db = await getDatabase();
    await db.insert('user_info', {
      "userid": userInfo.userId,
      "deviceid": userInfo.deviceId,
      "usertoken": userInfo.token,
      "fcmtoken": userInfo.fcmToken,
    });
  }

  Future<void> deleteDb() async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final dpPath = path.join(appDir.path, 'userinfo.db');
    await sql.deleteDatabase(dpPath);
  }
}
