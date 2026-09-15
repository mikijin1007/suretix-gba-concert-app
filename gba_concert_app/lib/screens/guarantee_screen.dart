import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 穩飛保障说明 —— 品牌核心信任讲透。担保出票/赔付规则/验票保真。
class GuaranteeScreen extends StatelessWidget {
  const GuaranteeScreen({super.key});

  // [icon, 标题, 说明]
  static const _items = [
    [
      LucideIcons.shieldCheck,
      '担保出票',
      '下单即锁定票源,48 小时内完成出票。逾期未出票全额退款并额外补偿 ¥200 无门槛券。'
    ],
    [
      LucideIcons.camera,
      '实体票实拍上传',
      '出票后第一时间上传实体票实拍照(含票面座位与防伪),你在订单里可随时查看,眼见为实。'
    ],
    [
      LucideIcons.badgeCheck,
      '验票保真',
      '每张票经过票源核验与票权确认后才交付,杜绝假票、一票多卖。假一赔十。'
    ],
    [
      LucideIcons.umbrella,
      '现场兜底赔付',
      '若因平台原因无法正常入场,按 ¥500/票 即时赔付(单笔上限 ¥2,000),并协助现场应急。'
    ],
    [
      LucideIcons.truck,
      '顺丰保价配送',
      '实体票顺丰保价寄送,全程可追踪;也可选择现场当面交付,双重取票方式更安心。'
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('穩飛保障',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _hero(),
          const SizedBox(height: 20),
          ..._items.map((e) => _item(e)),
          const SizedBox(height: 8),
          _footer(),
        ],
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x33E5477B), Color(0x0DE5477B)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x4DE5477B))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  gradient: AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(LucideIcons.shieldCheck,
                  size: 24, color: AppColors.amberInk),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('穩出票 · 稳观演',
                        style: AppTheme.displaySerif(size: 22)),
                    const SizedBox(height: 2),
                    const Text('平台已出票 128,000+ · 0 违约',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          const Text('买演唱会票最怕跳票、假票。穩飛用「担保出票 + 实拍上传 + 赔付兜底」把风险扛在平台这边,让你放心抢票。',
              style: TextStyle(
                  fontSize: 12.5, height: 1.6, color: AppColors.textSecondary)),
        ]),
      );

  Widget _item(List<Object> e) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(e[0] as IconData, size: 20, color: AppColors.amber),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e[1] as String,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(e[2] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: AppColors.textSecondary)),
                  ]),
            ),
          ]),
        ),
      );

  Widget _footer() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: const [
          Icon(LucideIcons.fileText, size: 14, color: AppColors.textFaint),
          SizedBox(width: 8),
          Expanded(
            child: Text('以上保障受《购票服务协议》约束,具体赔付以协议条款为准。',
                style: TextStyle(
                    fontSize: 10.5, height: 1.5, color: AppColors.textFaint)),
          ),
        ]),
      );
}
