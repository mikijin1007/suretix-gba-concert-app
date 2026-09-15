import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'traveler_screen.dart';
import 'address_screen.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';
import 'guarantee_screen.dart';
import 'favorites_screen.dart';
import 'support_chat_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'agreement_screen.dart';
import 'auth_flow_screen.dart';

/// 我的 tab —— 账户 + 信任战报 + 出行人/地址/设置入口
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 110),
        children: [
          _header(),
          _trustStats(),
          _quickGrid(context),
          _menuList(context),
          _logout(context),
        ],
      ),
    );
  }

  Widget _logout(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: PressableScale(
          onTap: () => _confirmLogout(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x55FF4D4D))),
            child: const Text('退出登录',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B6B))),
          ),
        ),
      );

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('退出登录',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        content: const Text('确定要退出当前账号吗?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthFlowScreen()),
                (r) => false),
            child: const Text('退出',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
        child: Row(children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(fit: StackFit.expand, children: [
              // 头像图（黑底圆形）
              Container(
                decoration: const BoxDecoration(
                    color: Color(0xFF000000), shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/avatar_face.png',
                    fit: BoxFit.contain),
              ),
              // 圆圈内描边（粉色环，叠在图上）
              DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.amber, width: 2.5)),
              ),
            ]),
          ),
          const SizedBox(width: 14),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('穩飛用户',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('138****1206',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ]),
          const Spacer(),
        ]),
      );

  // 信任战报 banner(整图轮播：穩飛保障 · 出票 · 优惠 …)
  Widget _trustStats() => const Padding(
        padding: EdgeInsets.fromLTRB(22, 12, 22, 18),
        child: _TrustBannerCarousel(),
      );

  // 快捷入口格
  Widget _quickGrid(BuildContext context) {
    final items = [
      ['assets/images/kg_traveler.png', '出行人 / 证件', () => AppRoute.to(context, const TravelerScreen())],
      ['assets/images/kg_address.png', '收货地址', () => AppRoute.to(context, const AddressScreen())],
      ['assets/images/kg_fav.png', '我的收藏', () => AppRoute.to(context, const FavoritesScreen())],
      ['assets/images/kg_support.png', '在线客服', () => AppRoute.to(context, const SupportChatScreen())],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      child: Row(
          children: items.map((it) {
        return Expanded(
          child: PressableScale(
            onTap: it[2] as VoidCallback?,
            child: Column(children: [
              Container(
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Image.asset(it[0] as String, fit: BoxFit.contain),
              ),
              const SizedBox(height: 6),
              Text(it[1] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ]),
          ),
        );
      }).toList()),
    );
  }

  Widget _menuList(BuildContext context) {
    final items = [
      [LucideIcons.shieldCheck, '穩飛保障说明', () => AppRoute.to(context, const GuaranteeScreen())],
      [LucideIcons.fileText, '购票服务协议', () => AppRoute.to(context, const AgreementScreen())],
      [LucideIcons.gift, '我的优惠券', () => AppRoute.to(context, const WalletScreen())],
      [LucideIcons.bell, '消息通知', () => AppRoute.to(context, const NotificationsScreen())],
      [LucideIcons.circleHelp, '帮助中心', () => AppRoute.to(context, const HelpScreen())],
      [LucideIcons.settings, '设置', () => AppRoute.to(context, const SettingsScreen())],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(
            children: List.generate(items.length, (i) {
          return Column(children: [
            PressableScale(
              onTap: items[i][2] as VoidCallback?,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(children: [
                  Icon(items[i][0] as IconData,
                      size: 17, color: AppColors.amber),
                  const SizedBox(width: 12),
                  Text(items[i][1] as String,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(LucideIcons.chevronRight,
                      size: 16, color: AppColors.textFaint),
                ]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                  color: AppColors.line,
                  height: 1,
                  indent: 44,
                  endIndent: 14),
          ]);
        })),
      ),
    );
  }
}

/// 信任战报 banner 轮播(每 4 秒横向滑动自动切换 + 手动滑动)
class _TrustBannerCarousel extends StatefulWidget {
  const _TrustBannerCarousel();

  @override
  State<_TrustBannerCarousel> createState() => _TrustBannerCarouselState();
}

class _TrustBannerCarouselState extends State<_TrustBannerCarousel> {
  static const _banners = [
    'assets/images/banner_trust.png',
    'assets/images/banner_trust2.png',
    'assets/images/banner_trust3.png',
  ];

  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _banners.length;
      if (next == 0) {
        // 从最后一张回到第一张：先滑到位再无动画归位，避免长距离回滚
        _controller
            .animateToPage(_banners.length,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut)
            .then((_) {
          if (mounted && _controller.hasClients) _controller.jumpToPage(0);
        });
      } else {
        _controller.animateToPage(next,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut);
      }
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
    // 末尾追加第一张的副本，用于无缝循环滑动
    final pages = [..._banners, _banners.first];
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          controller: _controller,
          itemCount: pages.length,
          onPageChanged: (i) => _index = i % _banners.length,
          itemBuilder: (_, i) => Image.asset(
            pages[i],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
