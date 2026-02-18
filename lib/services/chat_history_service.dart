import 'package:hive_flutter/hive_flutter.dart';

import 'package:sanad_app/model/chat_conversation_model.dart';

class ChatHistoryService {
  static const _boxName = 'chat_conversations';
  static const _keyList = 'list';

  static Box<dynamic> get _box => Hive.box(_boxName);

  static List<ChatConversationModel> getAll() {
    final raw = _box.get(_keyList);
    if (raw == null || raw is! List) return [];
    final list = List<dynamic>.from(raw);
    final conversations = list
        .map((e) => ChatConversationModel.fromMap(
            Map<String, dynamic>.from(e is Map ? e : {})))
        .toList();
    conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return conversations;
  }

  static Future<void> saveAll(List<ChatConversationModel> conversations) async {
    await _box.put(
      _keyList,
      conversations.map((c) => c.toMap()).toList(),
    );
  }

  static Future<void> saveConversation(ChatConversationModel conversation) async {
    final list = getAll();
    final idx = list.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      list[idx] = conversation;
    } else {
      list.insert(0, conversation);
    }
    await saveAll(list);
  }

  static Future<void> deleteConversation(String id) async {
    final list = getAll().where((c) => c.id != id).toList();
    await saveAll(list);
  }
}
