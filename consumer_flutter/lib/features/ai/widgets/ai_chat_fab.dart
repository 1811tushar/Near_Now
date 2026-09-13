import 'package:flutter/material.dart';
import '../pages/ai_chat_page.dart';

class AiChatFab extends StatelessWidget {
  const AiChatFab({super.key});
  @override Widget build(BuildContext context) => FloatingActionButton.extended(
    heroTag: 'near-now-ai-chat', icon: const Icon(Icons.auto_awesome), label: const Text('Ask NearNow'),
    onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const FractionallySizedBox(heightFactor: .94, child: AiChatPage())),
  );
}
