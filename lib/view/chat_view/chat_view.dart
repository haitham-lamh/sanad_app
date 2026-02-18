import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/chat_conversation_model.dart';
import 'package:sanad_app/services/chat_history_service.dart';
import 'package:sanad_app/services/gemini_service.dart';
import 'package:sanad_app/services/sanad_agent.dart';
import 'package:sanad_app/view/widgets/chat_bubble.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  List<ChatConversationModel> _conversations = [];
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadCurrentConversation();
  }

  void _loadConversations() {
    setState(() {
      _conversations = ChatHistoryService.getAll();
    });
  }

  void _loadCurrentConversation() {
    if (_currentConversationId == null) {
      setState(() => _messages.clear());
      return;
    }
    final list = _conversations.where((c) => c.id == _currentConversationId).toList();
    if (list.isEmpty) return;
    final conv = list.first;
    setState(() {
      _messages.clear();
      for (final m in conv.messages) {
        _messages.add({
          'isUser': m.isUser,
          'text': m.text,
          'createdAt': m.createdAt,
        });
      }
    });
  }

  void _startNewConversation() {
    setState(() {
      _currentConversationId = null;
      _messages.clear();
    });
  }

  void _selectConversation(String? id) {
    if (id == null) return;
    setState(() => _currentConversationId = id);
    _loadConversations();
    _loadCurrentConversation();
  }

  Future<void> _saveCurrentConversation() async {
    if (_currentConversationId == null || _messages.isEmpty) return;
    final list = _conversations.where((c) => c.id == _currentConversationId).toList();
    if (list.isEmpty) return;
    final conv = list.first;
    final updated = ChatConversationModel(
      id: conv.id,
      title: conv.title,
      messages: _messages
          .map((m) => ChatMessageModel(
                isUser: m['isUser'] as bool,
                text: m['text'] as String,
                createdAt: m['createdAt'] as DateTime,
              ))
          .toList(),
      createdAt: conv.createdAt,
    );
    await ChatHistoryService.saveConversation(updated);
    _loadConversations();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();

    if (_currentConversationId == null) {
      _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
      final title = text.length > 25 ? '${text.substring(0, 25)}...' : text;
      final newConv = ChatConversationModel(
        id: _currentConversationId!,
        title: title,
        messages: [],
        createdAt: DateTime.now(),
      );
      await ChatHistoryService.saveConversation(newConv);
      _loadConversations();
    }

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'createdAt': DateTime.now(),
      });
      _loading = true;
    });
    _scrollToBottom();

    final history = _messages
        .map((m) => {
              'role': (m['isUser'] as bool) ? 'user' : 'model',
              'text': m['text'] as String,
            })
        .toList();

    final result = await GeminiService.sendMessage(history);

    if (!mounted) return;

    if (result.functionCall != null) {
      final name = result.functionCall!.name;
      final confirm = name == 'create_tasks'
          ? await SanadAgent.createTasksFromCall(result.functionCall!.args)
          : name == 'create_task'
              ? await SanadAgent.createTaskFromCall(result.functionCall!.args)
              : result.text ?? 'لم أستطع تنفيذ الطلب.';
      setState(() {
        _loading = false;
        _messages.add({
          'isUser': false,
          'text': confirm,
          'createdAt': DateTime.now(),
        });
      });
    } else {
      setState(() {
        _loading = false;
        _messages.add({
          'isUser': false,
          'text': result.text ?? 'لم أستطع الرد.',
          'createdAt': DateTime.now(),
        });
      });
    }
    _scrollToBottom();
    await _saveCurrentConversation();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تحدث مع سنـــد',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/sanad_icon.png',
                width: 40,
                height: 40,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _startNewConversation,
                icon: const Icon(Icons.add_comment, size: 20),
                label: const Text('محادثة جديدة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              if (_conversations.isNotEmpty)
                SizedBox(
                  width: 180,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currentConversationId,
                      isExpanded: true,
                      hint: Text(
                        'المحادثات السابقة',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontSize: 13,
                        ),
                      ),
                      items: _conversations
                          .map((c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(
                                  c.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.getTextPrimaryColor(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: _selectConversation,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            color: const Color.fromARGB(134, 114, 108, 201),
            height: 4,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final m = _messages[i];
                final isUser = m['isUser'] as bool;
                final msg = m['text'] as String;
                final createdAt = m['createdAt'] as DateTime?;
                if (isUser) {
                  return ChatBubble(text: msg, createdAt: createdAt);
                }
                return ChatBubbleForFrind(
                    text: msg, createdAt: createdAt);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        children: [
          IconButton(
            onPressed: _loading ? null : _send,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_loading,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
              cursorColor: AppTheme.primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.getCardBackgroundColor(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                hintTextDirection: TextDirection.rtl,
                hintText: 'اكتب رسالتك...',
                hintStyle: TextStyle(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
        ],
      ),
    );
  }
}
