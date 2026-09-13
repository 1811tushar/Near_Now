import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_message.dart';
import '../../products/models/product_model.dart';

class AiChatService {
  final ApiClient _client;
  AiChatService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<String> _sessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('nearnow_ai_session_id');
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'flutter-session-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('nearnow_ai_session_id', id);
    return id;
  }

  Future<ChatMessage> send({required String assistant, required String message, String? sessionId}) async {
    final sid = sessionId ?? await _sessionId();
    final path = assistant == 'shopping' ? '/ai/chat/shopping' : '/ai/chat/order-support';
    final data = await _client.post(path, body: {'sessionId': sid, 'message': message});
    final map = Map<String, dynamic>.from(data as Map);
    final products = ((map['products'] as List?) ?? const [])
        .whereType<Map>()
        .map((p) => ProductModel.fromApi(Map<String, dynamic>.from(p)))
        .toList();
    final requires = map['requires_human_approval'] == true;
    final payload = map['action_payload'] as Map?;
    final orderId = payload?['order_id']?.toString();
    final action = map['proposed_action']?.toString();
    return ChatMessage(id: DateTime.now().toIso8601String(), isUser: false, text: (map['message'] ?? '').toString(),
      responseType: products.isNotEmpty ? ChatResponseType.productCards : requires ? ChatResponseType.confirmationButton : ChatResponseType.text,
      products: products, actionLabel: action == 'CANCEL_ORDER' ? 'Cancel order' : 'Confirm', actionId: orderId, actionType: action);
  }

  Future<void> confirm({required ChatMessage message, required bool confirmed}) async {
    if (!confirmed || message.actionType != 'CANCEL_ORDER' || message.actionId == null) return;
    await _client.put('/orders/${message.actionId}/cancel');
  }
}
