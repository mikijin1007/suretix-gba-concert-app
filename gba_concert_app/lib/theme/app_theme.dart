import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 暗色电影票务风 · 暖金 —— 复用 Figma 稿视觉语言
class AppColors {
  static const bg = Color(0xFF0A0A0B); // 近黑主背景
  static const bgElevate = Color(0xFF141416);
  static const card = Color(0xFF161618);
  static const cardBorder = Color(0xFF232326);
  static const line = Color(0xFF202023);

  // ── 配色方向切换 ──
  // scheme 1 = 翡冷翠主 + 玫红点睛(信任优先) · scheme 2 = 玫红主 + 翡冷翠确认(潮流优先)
  static const int scheme = 2;

  // 主强调色(token 名沿用 amber* 不改，避免全站改引用；只换色值)
  static const amber = scheme == 1 ? Color(0xFF2FBE8F) : Color(0xFFE5477B);
  static const amberBright = scheme == 1 ? Color(0xFF5FE0B4) : Color(0xFFFF6FA0);
  static const amberDeep = scheme == 1 ? Color(0xFF1C8A66) : Color(0xFFB02458);
  static const amberInk = scheme == 1 ? Color(0xFF04211A) : Color(0xFF2A0512);
  static const amberSoft = scheme == 1 ? Color(0xFF9FD9C4) : Color(0xFFE7A8BE);

  // 信任/确认信号色：方案1=玫红点睛(与绿主对比)，方案2=翡冷翠确认(与玫红主对比)
  static const green = scheme == 1 ? Color(0xFF2FBE8F) : Color(0xFF2FBE8F); // 現票/已确认恒绿
  static const deal = scheme == 1 ? Color(0xFFE5477B) : Color(0xFFFF8A5A); // 紧迫/特惠点睛

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9A9A9E);
  static const textTertiary = Color(0xFF8A8A8E);
  static const textFaint = Color(0xFF6A6A6E);

  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amberBright, amberDeep],
  );

  static LinearGradient scrim() => const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xEB000000),
          Color(0x59000000),
          Color(0x00000000),
        ],
        stops: [0.08, 0.45, 0.75],
      );
}

class AppRadius {
  static const card = 20.0;
  static const pill = 24.0;
  static const chip = 16.0;
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.amber,
        surface: AppColors.card,
        background: AppColors.bg,
      ),
      textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }

  /// 优雅衬线 + 斜体：hero 展示字（薛之谦 天外来物）
  static TextStyle displaySerif({double size = 34, Color? color}) =>
      GoogleFonts.notoSerifSc(
        fontSize: size,
        height: 1.05,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: color ?? AppColors.textPrimary,
      );
}
