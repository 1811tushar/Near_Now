import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';
import '../widgets/smart_message_renderer.dart';
import '../../../core/constants/app_colors.dart';

class AiChatPage extends StatefulWidget {
  final String assistant;
  const AiChatPage({super.key, this.assistant = 'order-support'});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _service = AiChatService();
  late String _assistant;
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _assistant = widget.assistant;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toIso8601String(),
        text: text,
        isUser: true,
      ));
      _controller.clear();
      _loading = true;
    });
    _scrollToEnd();
    try {
      final response =
          await _service.send(assistant: _assistant, message: text);
      if (!mounted) return;
      setState(() {
        _messages.add(response);
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().toIso8601String(),
          isUser: false,
          text: 'Sorry, something went wrong: $e',
        ));
        _loading = false;
      });
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleConfirmation(ChatMessage m, bool yes) async {
    try {
      await _service.confirm(message: m, confirmed: yes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(yes ? 'Action completed.' : 'Action cancelled.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  Widget _buildMessageBubble(ChatMessage m) {
    if (m.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 38, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.meadow,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            m.text,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SmartMessageRenderer(
        message: m,
        onConfirmation: (yes) => _handleConfirmation(m, yes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('NearNow Assistant'),
        backgroundColor: AppColors.paper,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _assistant,
                items: const [
                  DropdownMenuItem(
                      value: 'order-support', child: Text('Orders')),
                  DropdownMenuItem(
                      value: 'shopping', child: Text('Shopping')),
                ],
                onChanged: (v) => setState(() => _assistant = v ?? _assistant),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.meadow),
                      ),
                    ),
                  );
                }
                return _buildMessageBubble(_messages[i]);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask NearNow AI anything...',
                        filled: true,
                        fillColor: AppColors.paper,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.meadow),
                    onPressed: _loading ? null : _send,
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    tooltip: 'Send message',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}