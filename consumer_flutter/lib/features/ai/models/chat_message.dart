import '../../products/models/product_model.dart';

enum ChatResponseType { text, productCards, confirmationButton }

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final ChatResponseType responseType;
  final List<ProductModel> products;
  final String? actionLabel;
  final String? actionId;
  final String? actionType;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.responseType = ChatResponseType.text,
    this.products = const [],
    this.actionLabel,
    this.actionId,
    this.actionType,
  });
}
