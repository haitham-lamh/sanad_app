class ChatConversationModel {
  final String id;
  final String title;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;

  ChatConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static ChatConversationModel fromMap(Map<String, dynamic> map) {
    final rawMsgs = map['messages'];
    final msgs = rawMsgs is List
        ? (rawMsgs)
            .map((e) => ChatMessageModel.fromMap(
                Map<String, dynamic>.from(e is Map ? e : <String, dynamic>{})))
            .toList()
        : <ChatMessageModel>[];
    return ChatConversationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'محادثة',
      messages: msgs,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _toInt(map['createdAt']) ?? 0,
      ),
    );
  }
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

class ChatMessageModel {
  final bool isUser;
  final String text;
  final DateTime createdAt;

  ChatMessageModel({
    required this.isUser,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'isUser': isUser,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static ChatMessageModel fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      isUser: map['isUser'] == true,
      text: map['text']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _toInt(map['createdAt']) ?? 0,
      ),
    );
  }
}
