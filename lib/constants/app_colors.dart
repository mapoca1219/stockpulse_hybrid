import 'package:flutter/material.dart';

class AppColors {
  // =========================================================================
  // SWISS EDITORIAL & HYPER-CONTRAST PALETTE
  // Inspired by Teenage Engineering, Linear Light, and Stripe Systems
  // =========================================================================

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F5F7);      // Technical paper grey (#F4F5F7)
  static const Color surface = Color(0xFFFFFFFF);         // Pure white (#FFFFFF)
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceSubtle = Color(0xFFF9FAFB);   // Subtle neutral background (#F9FAFB)
  static const Color surfaceMuted = Color(0xFFF3F4F6);    // Crisp divider fill

  // Borders & Dividers
  static const Color border = Color(0xFF111827);          // Solid deep ink border (1.5px solid #111827)
  static const Color borderMuted = Color(0xFFE5E7EB);     // Subtle hairline divider (#E5E7EB)
  static const Color borderHighlight = Color(0xFF111827); // High contrast border

  // -------------------------------------------------------------------------
  // Primary Accent: International Orange / Vibrant Vermilion (#FF4500)
  // (Cloud AI Stage / Critical Alerts / In-Cloud Inferences / Primary Actions)
  // -------------------------------------------------------------------------
  static const Color internationalOrange = Color(0xFFFF4500);
  static const Color internationalOrangeMuted = Color(0x1FFF4500); // 12% opacity
  static const Color sunsetCoral = internationalOrange;           // Direct alias for backward compat
  static const Color sunsetCoralMuted = internationalOrangeMuted;

  // -------------------------------------------------------------------------
  // Secondary Accent: Electric Cobalt Blue (#0055FF)
  // (Local Edge AI / Gemini Nano 4 / On-Device Inferences / Zero-Egress)
  // -------------------------------------------------------------------------
  static const Color cobaltBlue = Color(0xFF0055FF);
  static const Color cobaltBlueMuted = Color(0x1A0055FF);         // 10% opacity
  static const Color cyberLime = cobaltBlue;                      // Mapped to Cobalt Blue for theme refactor
  static const Color cyberLimeMuted = cobaltBlueMuted;
  static const Color cyberLimeGlow = Color(0x330055FF);

  // -------------------------------------------------------------------------
  // Health & Operational States
  // -------------------------------------------------------------------------
  // Healthy & Live Online: Emerald Green (#059669) over (#ECFDF5)
  static const Color emeraldGreen = Color(0xFF059669);
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color success = emeraldGreen;

  // Simulated Offline Mode: Technical Amber (#FEF3C7 bg, #D97706 border, #92400E text)
  static const Color offlineBg = Color(0xFFFEF3C7);
  static const Color offlineBorder = Color(0xFFD97706);
  static const Color offlineText = Color(0xFF92400E);
  static const Color offline = Color(0xFFD97706);

  // Status & Telemetry Accents
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0055FF);
  static const Color electricCyan = Color(0xFF0055FF);            // High contrast cobalt for telemetry
  static const Color electricCyanMuted = Color(0x1A0055FF);

  // -------------------------------------------------------------------------
  // Typography Palette (Ultra-High Contrast Editorial)
  // -------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF090D16);             // Deep ink black (#090D16)
  static const Color textSecondary = Color(0xFF374151);           // Dark slate grey (#374151)
  static const Color textMuted = Color(0xFF6B7280);               // Neutral slate (#6B7280)
  static const Color textDark = Color(0xFF090D16);
  static const Color textLight = Color(0xFFFFFFFF);

  // -------------------------------------------------------------------------
  // High-Contrast Technical Gradients
  // -------------------------------------------------------------------------
  static const LinearGradient nanoGradient = LinearGradient(
    colors: [Color(0xFF0055FF), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cloudGradient = LinearGradient(
    colors: [Color(0xFFFF4500), Color(0xFFFF6A3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hybridPulseGradient = LinearGradient(
    colors: [Color(0xFF0055FF), Color(0xFFFF4500)],
    stops: [0.0, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
