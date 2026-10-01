
import 'package:flutter/material.dart';
import '../pages/ai_chat_page.dart';
import '../../../core/constants/app_colors.dart';

class AiChatFab extends StatelessWidget {
  const AiChatFab({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        heroTag: 'near-now-ai-chat',
        backgroundColor: AppColors.meadow,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.smart_toy_outlined),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: AppColors.paper,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => FractionallySizedBox(
            heightFactor: .94,
            child: AiChatPage(),
          ),
        ),
      );
}
