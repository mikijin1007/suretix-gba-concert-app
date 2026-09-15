import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'package_tab_screen.dart';
import 'order_center_screen.dart';
import 'profile_screen.dart';

/// 全局底栏骨架 —— 4 tab: 首页/套餐/订单/我的。切 tab 不 push 不带返回。
class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => MainShellState();

  /// 供子页跳转指定 tab（如支付成功回订单页）
  static void go(BuildContext context, int tab) {
    final state = context.findAncestorStateOfType<MainShellState>();
    state?.setTab(tab);
  }
}

class MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  void setTab(int t) => setState(() => _tab = t);

  // [svg 路径, 标签, 视觉归一尺寸] —— 统一缩小到一致大小
  static const _navs = [
    ['assets/images/nav_home.svg', '首页', 19.0],
    ['assets/images/nav_package.svg', '套餐', 20.0],
    ['assets/images/nav_order.svg', '订单', 21.0],
    ['assets/images/nav_me.svg', '我的', 20.0],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          // key 随 tab 变化触发切换动画；用 IndexedStack 保活各页滚动位置
          child: KeyedSubtree(
            key: ValueKey(_tab),
            child: IndexedStack(index: _tab, children: const [
              HomeScreen(),
              PackageTabScreen(),
              OrderCenterScreen(),
              ProfileScreen(),
            ]),
          ),
        ),
        Positioned(left: 16, right: 16, bottom: 14, child: _bottomNav()),
      ]),
    );
  }

  Widget _bottomNav() => Glass(
        radius: BorderRadius.circular(26),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navs.length, (i) {
              final on = _tab == i;
              // 选中态平滑展开为金色胶囊(图标+文字横排)，标签宽度随选中动画伸缩。
              return PressableScale(
                onTap: () => setTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                      horizontal: on ? 16 : 12, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: on ? AppColors.amberGradient : null,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedScale(
                      scale: on ? 1.0 : 1.0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutBack,
                      child: SvgPicture.asset(
                        _navs[i][0] as String,
                        width: _navs[i][2] as double,
                        height: _navs[i][2] as double,
                        colorFilter: ColorFilter.mode(
                            on ? AppColors.amberInk : AppColors.textTertiary,
                            BlendMode.srcIn),
                      ),
                    ),
                    // 选中时标签横向展开；未选收起为 0 宽
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: on
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              const SizedBox(width: 7),
                              Text(_navs[i][1] as String,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.amberInk)),
                            ])
                          : const SizedBox.shrink(),
                    ),
                  ]),
                ),
              );
            })),
      );
}
