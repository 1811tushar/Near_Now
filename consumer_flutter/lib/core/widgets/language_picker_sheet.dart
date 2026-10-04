import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_spacing.dart';
import '../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Shows the app's language-selection bottom sheet.
///
/// Previously this exact UI was duplicated independently in both the Home
/// tab and the Profile screen. Both call sites now share this single
/// implementation, so a future third language only needs to be added once.
void showLanguagePicker(BuildContext context) {
  final localeProvider = context.read<LocaleProvider>();
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: RadioGroup<Locale>(
          groupValue: localeProvider.locale,
          onChanged: (value) {
            if (value != null) localeProvider.setLocale(value);
            Navigator.pop(sheetContext);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.selectLanguage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              // Language names are intentionally shown in their own
              // language (not translated) — this is the standard pattern
              // for language pickers everywhere.
              const RadioListTile<Locale>(
                title: Text('English'),
                value: Locale('en'),
              ),
              const RadioListTile<Locale>(
                title: Text('Español'),
                value: Locale('es'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      );
    },
  );
}
