import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class Chat {
  final int id;
  final String name;
  List<String> messages;

  Chat({@required this.id, this.messages, @required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'messages': jsonEncode(messages),
    };
  }

  @override
  String toString() {
    return 'Chat{id: $id, name: $name, messages: ${messages.toString()}}';
  }
}

class DatabaseBrain {
  final Future<Database> database;
  DatabaseBrain({@required this.database});

  Future<void> insertChat(Chat chat) async {
    final Database db = await database;

    await db.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Chat>> getChats() async {
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('chats');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Chat(
        name: maps[i]['name'],
        id: maps[i]['id'],
        messages: jsonDecode(maps[i]['messages']).cast<String>(),
      );
    });
  }

  Future<void> updateChat(Chat chat) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'chats',
      chat.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [chat.id],
    );
  }
}
