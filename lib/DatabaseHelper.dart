import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:project/Profile.dart';

class DatabaseHelper {
  late Database _database;
  DatabaseHelper();

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'User.db');

    _database = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS User (
          uid TEXT PRIMARY KEY,
          email TEXT,
          username TEXT,
          phone INTEGER
        )
      ''');
    });
  }

  Future<void> updateSQLiteFromFirestore(String? uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (snapshot.exists) {
      String documentId = snapshot.id;
      UserProfile userProfile = UserProfile(
        uid: documentId,
        email: snapshot.data()!['email'],
        username: snapshot.data()!['username'],
        phone: snapshot.data()!['phone'],
      );
      await initDatabase();
      // Update SQLite record using the fetched data
      await updateSQLiteRecord(userProfile);
    }
  }
  Future<void> updateSQLiteRecord(UserProfile userProfile) async {
    try {
      if (!(_database.isOpen)) {
        await initDatabase();
      }

      List<Map<String, dynamic>> existingRecords = await _database.query(
        'User',
        where: 'uid = ?',
        whereArgs: [userProfile.uid],
      );

      if (existingRecords.isNotEmpty) {
        await _database.update(
          'User',
          userProfile.toMap(),
          where: 'uid = ?',
          whereArgs: [userProfile.uid],
        );
      } else {
        await _database.insert(
          'User',
          userProfile.toMap(),
        );
      }
    } catch (e) {
      print('Error updating or inserting SQLite record: $e');
    }
  }


  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      if (!(_database.isOpen)) {
        await initDatabase();
      }
      final List<Map<String, dynamic>> maps = await _database.query(
        'User',
        where: 'uid = ?',
        whereArgs: [uid],
      );

      if (maps.isNotEmpty) {
        return UserProfile.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}