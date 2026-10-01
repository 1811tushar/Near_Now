
import 'package:flutter/material.dart';

/// NearNow brand tokens — "Meadow / Citrus / Paper" direction, approved
/// design-review pass. See NearNow_Consumer_Design_Handoff for rationale.
class AppColors {
  AppColors._();

  // Brand
  static const Color meadow = Color(0xFF146C43); // primary — trust, freshness
  static const Color meadowDark = Color(0xFF0E5334);
  static const Color citrus = Color(0xFFC6E86B); // accent — CTAs, delivery badges
  static const Color citrusDark = Color(0xFF7C9A2E);

  // Neutrals
  static const Color paper = Color(0xFFFAF8F1); // background — warm cream, not sterile white
  static const Color ink = Color(0xFF12261C); // near-black, green-tinted text
  static const Color inkSoft = Color(0xFF5B6B60); // secondary text
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE7E3D6); // hairlines, dividers

  // Semantic
  static const Color error = Color(0xFF993C1D);
  static const Color success = Color(0xFF27500A);
  static const Color warning = Color(0xFF854F0B);

  // --- Back-compat aliases so existing widgets referencing the old names
  // keep compiling while every screen is migrated one PR at a time.
  static const Color primary = meadow;
  static const Color secondary = card;
  static const Color accent = citrus;
  static const Color grey = inkSoft;
  static const Color background = paper;

  // Category tint chips (used by CategoryIconIllustrations backgrounds)
  static const Color tint1 = Color(0xFFEAF3DE); // fruits & veg
  static const Color tint2 = Color(0xFFE1F5EE); // dairy
  static const Color tint3 = Color(0xFFFAECE7); // snacks
  static const Color tint4 = Color(0xFFE6F1FB); // beverages
  static const Color tint5 = Color(0xFFFAEEDA); // bakery
  static const Color tint6 = Color(0xFFEEEDFE); // atta/rice/dals
  static const Color tint7 = Color(0xFFFBEAF0); // masala
  static const Color tint8 = Color(0xFFF1EFE8); // frozen
}
