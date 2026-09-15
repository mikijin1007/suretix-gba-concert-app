import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 隐私政策 —— 信息收集与使用说明(分节)。
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  // [标题, 正文]
  static const _sections = [
    ['一、我们收集的信息',
        '为提供购票与住宿服务,我们会收集:账号信息(手机号)、实名信息(姓名与证件号,用于实名观演)、收货地址(用于实体票寄送)、订单与支付记录、设备信息与日志(用于安全风控)。'],
    ['二、信息的使用目的',
        '收集的信息仅用于:完成订单履约与出票、实名入场核验、票品寄送、售后与退改处理、消息通知推送、平台安全与反欺诈。我们不会将信息用于与服务无关的用途。'],
    ['三、证件信息的特别保护',
        '证件号码采用加密存储与脱敏展示(仅显示部分位数)。仅在演出方要求实名核验时,按最小必要原则传输给对应演出方或场馆,核验完成后不作二次留存。'],
    ['四、信息共享范围',
        '为完成服务,我们会在必要范围内与以下方共享:演出方与场馆(实名核验)、合作酒店(住宿预订)、物流服务商(票品寄送)、支付机构(交易处理)。我们要求上述各方同等履行保密义务。'],
    ['五、信息存储与保留',
        '信息存储于中国境内服务器。订单与实名信息在服务完成后保留 3 年(用于售后与合规审计),超期后进行匿名化或删除。'],
    ['六、你的权利',
        '你可以随时查询、更正个人信息;可在「我的 → 出行人 / 证件」与「收货地址」中自行增删;可通过「账号与安全 → 注销账号」申请删除全部数据。'],
    ['七、Cookie 与同类技术',
        '我们使用本地存储保存登录状态与偏好设置,以提升使用体验。你可以通过清除应用缓存来移除这些本地数据。'],
    ['八、未成年人保护',
        '不满 14 周岁的未成年人使用本服务,应由监护人代为操作并同意本政策。我们不会主动收集未成年人的非必要信息。'],
    ['九、政策更新与联系',
        '本政策更新后将在应用内公示。如对隐私问题有疑问,可通过「我的 → 在线客服」联系我们,或发送邮件至 privacy@suretix.example。'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('隐私政策',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('穩飛 SureTix · 个人信息保护',
                  style:
                      TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
            ]),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const Text('穩飛隐私政策',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('生效日期:2026 年 8 月 1 日',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.3))),
            child: const Text('我们仅收集为完成购票与住宿服务所必需的信息,并按最小必要原则使用。你的证件信息采用加密存储与脱敏展示。',
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 20),
          ..._sections.map((s) => _section(s[0], s[1])),
          const SizedBox(height: 6),
          const Text('感谢你信任穩飛。',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textTertiary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _section(String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.amber)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.7, color: AppColors.textSecondary)),
        ]),
      );
}
