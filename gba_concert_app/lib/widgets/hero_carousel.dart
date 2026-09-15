import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// 本周王牌 · 英雄大卡轮播（参考 Figma The Little Mermaid 大卡）：
/// 全幅海报 + KenBurns + scrim 压字，多场自动轮播(5s) + 圆点指示器 +
/// 左下信息块(tagline/大标题/副标题/地点/评分/价格 + 立即抢票药丸)。
class HeroSlide {
  final String tagline; // 官方售罄 · 我们仍有票
  final String title; // 周杰伦
  final String subtitle; // 嘉年华巡演
  final String meta; // 启德体育园 · 8月29–31日 · 3场
  final String price; // ¥3,280
  final int seed; // 海报图
  const HeroSlide({
    required this.tagline,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.price,
    required this.seed,
  });
}

class HeroCarousel extends StatefulWidget {
  final List<HeroSlide> slides;
  final ValueChanged<int>? onTapSlide;
  const HeroCarousel({super.key, required this.slides, this.onTapSlide});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.slides.length <= 1) return;
      final next = (_index + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 320,
              child: Stack(
                children: [
                  // 轮播主体
                  PageView.builder(
                    controller: _controller,
                    itemCount: widget.slides.length,
                    onPageChanged: (i) {
                      setState(() => _index = i);
                      _startAuto(); // 手动滑动后重置自动计时
                    },
                    itemBuilder: (_, i) => _slide(widget.slides[i]),
                  ),
                  // 顶部标签行（固定，不随轮播）：本周王牌 + 右侧收藏爱心同一行
                  Positioned(
                    top: 14,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _heroTag('本周王牌'),
                        const Spacer(),
                        const _HeartBadge(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 圆点指示器：移到卡片图片下方居中
          if (widget.slides.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.slides.length, (i) {
                final on = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: on ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: on ? AppColors.amber : const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slide(HeroSlide s) => PressableScale(
        onTap: () => widget.onTapSlide?.call(_index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            KenBurns(child: PosterBox(seed: s.seed)),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.scrim()),
            ),
            // 左下信息区
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. tagline 小胶囊
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s.tagline,
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 2. 大标题（衬线斜体）
                  Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.displaySerif(size: 33),
                  ),
                  const SizedBox(height: 2),
                  // 3. 副标题
                  Text(
                    s.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 4. 地点 meta 一行
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 13, color: Color(0xFFCFCFCF)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          s.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCFCFCF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 底部行：价格 + 立即抢票药丸
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: s.price,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber,
                          ),
                          children: const [
                            TextSpan(
                              text: '  起',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AmberButton(
                        '立即抢票',
                        onTap: () => widget.onTapSlide?.call(_index),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _heroTag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
}

/// 收藏心形（装饰）：半透明圆底 + 粉色心形（对应 Figma 右侧爱心）
class _HeartBadge extends StatelessWidget {
  const _HeartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: const Icon(LucideIcons.heart, size: 16, color: AppColors.amber),
    );
  }
}

/// 信任标（统一）：品牌承诺「穩出票」
class _TrustPill extends StatelessWidget {
  const _TrustPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x24E5477B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66E5477B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_user_outlined, size: 13, color: AppColors.amber),
          SizedBox(width: 4),
          Text(
            '穩出票',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
