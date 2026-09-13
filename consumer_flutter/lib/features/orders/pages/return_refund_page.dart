import 'package:flutter/material.dart';
import '../models/order_model.dart';

class ReturnRefundPage extends StatefulWidget {
  final OrderModel order;
  const ReturnRefundPage({super.key, required this.order});
  @override State<ReturnRefundPage> createState() => _ReturnRefundPageState();
}

class _ReturnRefundPageState extends State<ReturnRefundPage> {
  String _type = 'Return';
  String? _reason;
  bool _loading = false;
  static const reasons = ['Damaged item', 'Wrong item', 'Missing item', 'Quality issue', 'Changed my mind'];

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
    appBar: AppBar(title: const Text('Return / Refund')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Order #${widget.order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text('What do you need?', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'Return', label: Text('Return')), ButtonSegment(value: 'Refund', label: Text('Refund'))],
          selected: {_type},
          onSelectionChanged: (v) => setState(() => _type = v.first),
        ),
        const SizedBox(height: 24),
        const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _reason,
          hint: const Text('Select a reason'),
          items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => _reason = v),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (_reason == null || _loading) ? null : _submit,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Check request'),
          ),
        ),
      ]),
    ),
  );
}
