import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'support_chat_screen.dart';

/// 现场应急 —— 观演当天:应急凭证 + 一键客服 + 常见现场问题。后端接口预留。
class EmergencyScreen extends StatelessWidget {
  final String show;
  final String orderNo;
  const EmergencyScreen({
    super.key,
    this.show = '周杰伦 嘉年华巡演',
    this.orderNo = 'ST202608291',
  });

  // 常见现场问题 [问题, 处理指引]
  static const _faqs = [
    ['闸机刷不进 / 提示无效', '别慌,立即点上方「联系现场客服」,出示应急凭证,客服后台核验后引导人工通道入场。'],
    ['实体票没收到 / 忘带', '凭电子应急凭证 + 身份证到场馆「穩飛服务点」补办入场凭证,10 分钟内解决。'],
    ['找不到座位 / 分区', '出示票面座位号给现场引导员;内场企位为不对号自由站位,先到先站。'],
    ['演出延期 / 取消', '平台第一时间站内信通知,延期票自动顺延有效,取消全额退款并补偿。'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('现场应急',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          _voucher(),
          const SizedBox(height: 16),
          _contactRow(context),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 12),
            child: Text('常见现场问题',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          ..._faqs.map((f) => _faqCard(f)),
        ],
      ),
    );
  }

  // 应急凭证卡(二维码 mock)
  Widget _voucher() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x33E5477B), Color(0x0DE5477B)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x4DE5477B))),
        child: Column(children: [
          Row(children: [
            const Icon(LucideIcons.shieldAlert, size: 16, color: AppColors.amber),
            const SizedBox(width: 8),
            const Text('应急入场凭证',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('生效中',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.qrCode, size: 120, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 14),
          Text(show,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('订单号 $orderNo · 出示给现场客服核验',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ]),
      );

  Widget _contactRow(BuildContext context) => Row(children: [
        Expanded(
          child: _contactBtn(
              LucideIcons.headset, '联系现场客服', '7×24 在线', true,
              onTap: () => AppRoute.to(context, const SupportChatScreen())),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _contactBtn(
              LucideIcons.phone, '拨打应急热线', '400-888-0000', false,
              onTap: () => _callDialog(context)),
        ),
      ]);

  // 拨号确认
  void _callDialog(BuildContext context) => showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.bgElevate,
          title: const Text('拨打应急热线',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: const Text('将呼出 400-888-0000，现场客服 7×24 小时为你处理入场问题。',
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: const Text('取消',
                    style: TextStyle(color: AppColors.textSecondary))),
            TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('正在呼出 400-888-0000…'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: const Text('拨打',
                    style: TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w800))),
          ],
        ),
      );

  Widget _contactBtn(IconData icon, String title, String sub, bool primary,
          {VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              gradient: primary ? AppColors.amberGradient : null,
              color: primary ? null : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: primary
                  ? null
                  : Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            Icon(icon,
                size: 22,
                color: primary ? AppColors.amberInk : AppColors.amber),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primary ? AppColors.amberInk : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    fontSize: 10,
                    color: primary
                        ? const Color(0xCC2A0512)
                        : AppColors.textTertiary)),
          ]),
        ),
      );

  Widget _faqCard(List<String> f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(LucideIcons.circleHelp,
                      size: 15, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f[0],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 23),
                  child: Text(f[1],
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: AppColors.textSecondary)),
                ),
              ]),
        ),
      );
}
