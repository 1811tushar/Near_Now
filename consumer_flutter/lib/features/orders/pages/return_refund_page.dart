
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class ReturnRefundPage extends StatefulWidget {
  final OrderModel order;
  const ReturnRefundPage({super.key, required this.order});
  @override
  State<ReturnRefundPage> createState() => _ReturnRefundPageState();
}

class _ReturnRefundPageState extends State<ReturnRefundPage> {
  String _type = 'Return';
  String? _reason;
  bool _loading = false;
  static const reasons = ['Damaged item', 'Wrong item', 'Missing item', 'Quality issue', 'Changed my mind'];

  // Kept exactly as-is: this app never claims a return/refund request was
  // submitted when the backend has no endpoint for it yet.
  Future<void> _submit() async {
    if (_reason == null || _loading) return;
    setState(() => _loading = true);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Return / Refund unavailable'),
        content: const Text('The current Spring Boot API does not expose a customer return/refund submission endpoint yet. No request was created.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(title: const Text('Return / Refund')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppTheme.cardDepth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${widget.order.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.order.items.length} item(s) · ₹${widget.order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.tint4,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF185FA5)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "We're still building our return & refund system. You can start a request below, but it won't be submitted yet — please contact support if this is urgent.",
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('What do you need?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'Return', label: Text('Return')), ButtonSegment(value: 'Refund', label: Text('Refund'))],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.meadow,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Reason', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              hint: const Text('Select a reason'),
              items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _reason = v),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_reason == null || _loading) ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Check request'),
              ),
            ),
          ],
        ),
      );
}
