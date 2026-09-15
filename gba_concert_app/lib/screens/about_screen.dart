import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'agreement_screen.dart';
import 'privacy_screen.dart';

/// 关于穩飛 —— 品牌介绍 + 版本信息 + 数据战报 + 条款入口。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = 'v1.0.0';

  // [数字, 说明]
  static const _stats = [
    ['128,000+', '累计出票'],
    ['0', '违约记录'],
    ['4.9', '用户评分'],
    ['48h', '担保出票'],
  ];

  // [图标, 标题, 说明]
  static const _values = [
    [LucideIcons.shieldCheck, '穩出票', '担保出票 + 实拍上传,逾期全额退并补偿'],
    [LucideIcons.bedDouble, '一站式', '门票与酒店打包,一价全含省心之选'],
    [LucideIcons.headset, '有人管', '7×24 在线客服,现场应急兜底赔付'],
  ];

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('关于穩飛',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        children: [
          // 品牌头
          Column(children: [
            // 品牌 logo(全白版,适配深色背景)
            Image.asset(
              'assets/images/logo_white.png',
              width: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('穩飛 SureTix',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 14),
            const Text('大湾区观演一站式服务平台',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder)),
              child: const Text(_version,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary)),
            ),
          ]),
          const SizedBox(height: 24),
          // 数据战报
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder)),
            child: Row(
                children: _stats
                    .map((s) => Expanded(
                          child: Column(children: [
                            Text(s[0],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amber)),
                            const SizedBox(height: 4),
                            Text(s[1],
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary)),
                          ]),
                        ))
                    .toList()),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text('我们坚持的三件事',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          ),
          ..._values.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder)),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(11)),
                      child: Icon(v[0] as IconData,
                          size: 18, color: AppColors.amber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v[1] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(v[2] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                  ]),
                ),
              )),
          const SizedBox(height: 12),
          // 条款与检查更新
          Container(
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder)),
            child: Column(children: [
              _row(context, '购票服务协议', LucideIcons.fileText,
                  onTap: () => AppRoute.to(context, const AgreementScreen())),
              const Divider(height: 1, color: AppColors.line, indent: 14, endIndent: 14),
              _row(context, '隐私政策', LucideIcons.lock,
                  onTap: () => AppRoute.to(context, const PrivacyScreen())),
              const Divider(height: 1, color: AppColors.line, indent: 14, endIndent: 14),
              _row(context, '检查更新', LucideIcons.refreshCw,
                  trailing: '已是最新',
                  onTap: () => _toast(context, '当前已是最新版本 $_version')),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('穩飛 SureTix · 大湾区观演一站式服务平台\n© 2026 SureTix. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, height: 1.8, color: AppColors.textFaint)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, IconData icon,
          {String? trailing, VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 17, color: AppColors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            if (trailing != null)
              Text(trailing,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: AppColors.textFaint),
          ]),
        ),
      );
}
