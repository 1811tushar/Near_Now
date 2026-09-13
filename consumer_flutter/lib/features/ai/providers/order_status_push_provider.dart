import 'package:flutter/foundation.dart';

class OrderStatusPushProvider extends ChangeNotifier {
  final Map<String, String> _statuses = {};
  String? statusFor(String orderId) => _statuses[orderId];
  void update(String orderId, String status) { _statuses[orderId] = status; notifyListeners(); }
}
