
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import 'add_address_page.dart';
import '../../../l10n/app_localizations.dart';

class AddressListPage extends StatefulWidget {
  final String? uid;

  const AddressListPage({super.key, this.uid});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  String? _resolveUid(BuildContext context) {
    return widget.uid ?? context.read<AuthProvider>().user?.uid;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _resolveUid(context);
      if (uid != null) {
        context.read<AddressProvider>().fetchAddresses(uid);
      }
    });
  }

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home_outlined;
    if (l.contains('work') || l.contains('office')) return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final uid = _resolveUid(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(l10n.myAddresses)),
      body: uid == null
          ? Center(child: Text(l10n.pleaseLogInToViewAddresses))
          : addressProvider.isLoading
              ? const LoadingWidget()
              : addressProvider.error != null
                  ? EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: l10n.somethingWentWrong,
                      subtitle: addressProvider.error,
                      actionLabel: l10n.retry,
                      onAction: () => addressProvider.fetchAddresses(uid),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        if (addressProvider.addresses.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              l10n.tapAddressToUse,
                              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ...addressProvider.addresses.map((address) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              boxShadow: AppTheme.cardDepth,
                            ),
                            child: InkWell(
                              onTap: address.isDefault
                                  ? null
                                  : () {
                                      addressProvider.setDefaultAddress(uid, address.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.nowDeliveringTo(address.label)), duration: const Duration(seconds: 2)),
                                      );
                                    },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(color: AppColors.tint1, borderRadius: BorderRadius.circular(9)),
                                    alignment: Alignment.center,
                                    child: Icon(_iconFor(address.label), size: 18, color: AppColors.meadowDark),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(address.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                            if (address.isDefault) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(color: AppColors.tint1, borderRadius: BorderRadius.circular(5)),
                                                child: Text(
                                                  l10n.selected,
                                                  style: const TextStyle(color: AppColors.meadowDark, fontSize: 9.5, fontWeight: FontWeight.w800),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${address.addressLine}, ${address.city} - ${address.pincode}",
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: AppColors.inkSoft),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddAddressPage(existing: address)));
                                      } else if (value == 'delete') {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: Text(l10n.deleteAddressConfirmTitle),
                                            content: Text(l10n.deleteAddressConfirmBody),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
                                              TextButton(
                                                onPressed: () => Navigator.pop(dialogContext, true),
                                                child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          addressProvider.deleteAddress(uid, address.id);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (addressProvider.addresses.isEmpty)
                          EmptyStateWidget(icon: Icons.location_on_outlined, title: l10n.noSavedAddressesYet),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressPage())),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.meadow, width: 1.5, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+ Add new address',
                              style: const TextStyle(color: AppColors.meadow, fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
