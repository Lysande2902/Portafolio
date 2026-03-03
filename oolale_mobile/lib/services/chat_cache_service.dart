import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/message.dart';

class ChatCacheService {
  static final ChatCacheService _instance = ChatCacheService._internal();
  static Database? _database;

  factory ChatCacheService() => _instance;

  ChatCacheService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_cache.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            remitente_id TEXT,
            destinatario_id TEXT,
            contenido TEXT,
            media_url TEXT,
            media_type TEXT,
            created_at TEXT,
            leido INTEGER,
            estatus TEXT,
            is_pending INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE messages ADD COLUMN is_pending INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> saveMessage(Message message, {bool isPending = false}) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id.toString(),
        'remitente_id': message.senderId,
        'destinatario_id': message.receiverId,
        'contenido': message.content,
        'media_url': message.mediaUrl,
        'media_type': message.mediaType,
        'created_at': message.sentAt.toIso8601String(),
        'leido': message.isRead ? 1 : 0,
        'estatus': message.status,
        'is_pending': isPending ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveMessages(List<Message> messages) async {
    final db = await database;
    Batch batch = db.batch();
    for (var message in messages) {
      batch.insert(
        'messages',
        {
          'id': message.id.toString(),
          'remitente_id': message.senderId,
          'destinatario_id': message.receiverId,
          'contenido': message.content,
          'media_url': message.mediaUrl,
          'media_type': message.mediaType,
          'created_at': message.sentAt.toIso8601String(),
          'leido': message.isRead ? 1 : 0,
          'estatus': message.status,
          'is_pending': 0, // Mensajes de servidor nunca están pendientes
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Message>> getCachedMessages(String userId1, String userId2) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: '(remitente_id = ? AND destinatario_id = ?) OR (remitente_id = ? AND destinatario_id = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'],
        senderId: maps[i]['remitente_id'],
        receiverId: maps[i]['destinatario_id'],
        content: maps[i]['contenido'],
        mediaUrl: maps[i]['media_url'],
        mediaType: maps[i]['media_type'],
        sentAt: DateTime.parse(maps[i]['created_at']),
        isRead: maps[i]['leido'] == 1,
        explicitStatus: maps[i]['is_pending'] == 1 ? 'pending' : (maps[i]['estatus'] ?? 'sent'),
      );
    });
  }

  Future<List<Message>> getPendingMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'is_pending = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'],
        senderId: maps[i]['remitente_id'],
        receiverId: maps[i]['destinatario_id'],
        content: maps[i]['contenido'],
        mediaUrl: maps[i]['media_url'],
        mediaType: maps[i]['media_type'],
        sentAt: DateTime.parse(maps[i]['created_at']),
        isRead: maps[i]['leido'] == 1,
        explicitStatus: 'pending',
      );
    });
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }
}
