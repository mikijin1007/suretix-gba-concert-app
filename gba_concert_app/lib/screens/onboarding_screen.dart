import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

/// 首次登录轻量 onboarding —— 主打"担保出票"aha,非功能 tour。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  // [icon, 大标题, 说明]
  static const _pages = [
    [
      LucideIcons.shieldCheck,
      '担保出票 · 官方售罄也有票',
      '下单即锁定票源,48 小时内出票。逾期未出票全额退款并补偿,把跳票风险扛在我们这边。'
    ],
    [
      LucideIcons.camera,
      '实体票实拍 · 眼见为实',
      '出票后第一时间上传实体票实拍照,票面座位、防伪都看得见,不再担心"到底有没有票"。'
    ],
    [
      LucideIcons.umbrella,
      '现场兜底 · 进不去就赔',
      '万一现场无法入场,即时赔付 + 一键应急客服。买演唱会票,这次可以安心了。'
    ],
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()));
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pc.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
              child: PressableScale(
                ensureHitArea: true,
                onTap: _finish,
                child: const Text('跳过',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _slide(_pages[i]),
            ),
          ),
          _dots(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            child: PressableScale(
              onTap: _next,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8))
                    ]),
                child: Text(last ? '开始抢票' : '下一步',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberInk)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _slide(List<Object> p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0x33E5477B), Color(0x0DE5477B)]),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x4DE5477B))),
                child: Icon(p[0] as IconData, size: 44, color: AppColors.amber),
              ),
              const SizedBox(height: 36),
              Text(p[1] as String,
                  textAlign: TextAlign.center,
                  style: AppTheme.displaySerif(size: 24)),
              const SizedBox(height: 16),
              Text(p[2] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.7,
                      color: AppColors.textSecondary)),
            ]),
      );

  Widget _dots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (i) {
          final on = _page == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: on ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
                gradient: on ? AppColors.amberGradient : null,
                color: on ? null : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(4)),
          );
        }),
      );
}
