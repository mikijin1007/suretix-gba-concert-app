import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// 全站统一转场：iOS 式右滑推入 + 边缘手势返回（暗金高端调性）。
/// 用 AppRoute.to(context, page) 取代散落的 MaterialPageRoute。
class AppRoute {
  /// 全站统一转场：新页从右侧滑入 + 淡入 + 轻微缩放；旧页反向轻微平移+淡出并压暗。
  /// 比默认 Cupertino 更柔顺，配合暗色高端调性。支持边缘手势返回。
  static Future<T?> to<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push<T>(_SmoothRoute<T>(page));
}

class _SmoothRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  _SmoothRoute(this.page)
      : super(
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 340),
          opaque: true,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final secondaryCurved = CurvedAnimation(
              parent: secondary,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            // 新页：右滑入 + 淡入 + 从 0.96 缩放到 1
            final slideIn = Tween<Offset>(
              begin: const Offset(0.18, 0),
              end: Offset.zero,
            ).animate(curved);
            final fadeIn =
                Tween<double>(begin: 0.0, end: 1.0).animate(curved);
            final scaleIn =
                Tween<double>(begin: 0.96, end: 1.0).animate(curved);
            // 旧页：向左轻移 + 略微压暗
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.10, 0),
            ).animate(secondaryCurved);
            final dim = Tween<double>(begin: 0.0, end: 0.12)
                .animate(secondaryCurved);
            return SlideTransition(
              position: slideOut,
              child: Stack(children: [
                FadeTransition(
                  opacity: fadeIn,
                  child: SlideTransition(
                    position: slideIn,
                    child: ScaleTransition(scale: scaleIn, child: child),
                  ),
                ),
                // 前进时给旧页盖一层渐深黑罩
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: dim,
                    builder: (_, __) => Container(
                      color: Colors.black.withValues(alpha: dim.value),
                    ),
                  ),
                ),
              ]),
            );
          },
        );
}

/// Ken Burns：海报极慢缩放平移，first-view 高级动效（装饰性、只动 transform）
class KenBurns extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const KenBurns(
      {super.key,
      required this.child,
      this.duration = const Duration(seconds: 20)});

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        final scale = 1.0 + 0.10 * t; // 1.0→1.10 极慢
        final dx = -8.0 * t;
        final dy = -6.0 * t;
        return Transform(
          transform: Matrix4.identity()
            ..translate(dx, dy)
            ..scale(scale),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 海报：真实演唱会占位图（assets/images/concert_N.jpg），渐变作兜底
class PosterBox extends StatelessWidget {
  final double? width, height;
  final BorderRadius? radius;
  final int seed;
  final Widget? child;
  const PosterBox(
      {super.key,
      this.width,
      this.height,
      this.radius,
      this.seed = 0,
      this.child});

  static const _count = 9; // concert_1..concert_9
  static const _grads = [
    [Color(0xFF4A3A1E), Color(0xFF1A1206)],
    [Color(0xFF5E2A3A), Color(0xFF301018)],
    [Color(0xFF2A4A5E), Color(0xFF102630)],
    [Color(0xFF3A2A5E), Color(0xFF1A1030)],
    [Color(0xFF2A5E3A), Color(0xFF10301A)],
  ];

  @override
  Widget build(BuildContext context) {
    final g = _grads[seed % _grads.length];
    final asset = 'assets/images/concert_${(seed % _count) + 1}.jpg';
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: g,
        ),
      ),
      clipBehavior: radius != null ? Clip.antiAlias : Clip.none,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

enum StockKind { hard, guaranteed, deal }

class StockBadge extends StatelessWidget {
  final StockKind kind;
  final String text;
  const StockBadge(this.kind, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    late Color fg, bg, border;
    switch (kind) {
      case StockKind.hard:
        fg = AppColors.green;
        bg = const Color(0x264EC38A);
        border = const Color(0x664EC38A);
        break;
      case StockKind.guaranteed:
        fg = AppColors.amber;
        bg = const Color(0x24E8B65A);
        border = const Color(0x66E8B65A);
        break;
      case StockKind.deal:
        fg = AppColors.deal;
        bg = const Color(0x29FF785A);
        border = const Color(0x66FF785A);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

/// 手绘图标组通用渲染：图片资源 + 可选着色（tint 时用 srcIn 变纯色剪影，
/// 与文字同色；不 tint 时保留手绘粉彩原貌）。用于全局把语义主图标换成手绘图标。
class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color; // 传色=着色剪影；null=保留原图彩绘
  const AppIcon(this.asset, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset,
        width: size,
        height: size,
        color: color,
        colorBlendMode: color == null ? null : BlendMode.srcIn);
  }
}

class AmberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const AmberButton(this.text,
      {super.key,
      this.onTap,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: AppColors.amberGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: const [
            BoxShadow(color: Color(0x59C9962F), blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        // 居中：在 Expanded/等宽场景下文字也保持水平居中
        // (Container 有 padding 时不会强行撑宽，仅在被父级拉宽时生效)
        child: Center(
          widthFactor: 1,
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.amberInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

/// 按压缩放反馈（emil-design-eng 头号规则：scale 0.97 / 150ms easeOut）
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  /// 保证最小可点区域（ui-ux-pro-max P2：触控 ≥ 44×44）。
  /// 用于小图标按钮（铃铛/头像/圆形返回等）：视觉尺寸不变，命中区透明扩展到 44。
  final bool ensureHitArea;
  const PressableScale(
      {super.key,
      required this.child,
      this.onTap,
      this.scale = 0.97,
      this.ensureHitArea = false});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;
  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    if (widget.ensureHitArea) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: content,
      ),
    );
  }
}

/// 品牌统一返回键 —— 圆形卡片底 + 左箭头,替换系统 BackButton。
/// 用于 AppBar leading: const AppBackButton()
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PressableScale(
        ensureHitArea: true,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 15, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// 玻璃拟态容器
class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius? radius;
  final EdgeInsets? padding;
  const Glass({super.key, required this.child, this.radius, this.padding});

  @override
  Widget build(BuildContext context) {
    final r = radius ?? BorderRadius.circular(AppRadius.chip);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x991C1C1E),
            borderRadius: r,
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}
