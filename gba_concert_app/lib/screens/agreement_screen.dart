import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 购票服务协议 —— 条款正文(分节)。
class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  // [标题, 正文]
  static const _sections = [
    ['一、服务说明',
        '穩飛(SureTix)为用户提供演出门票与酒店住宿打包的一站式观演服务。用户通过平台购买的为「门票 + 住宿」或「门票 + 观演礼包」套餐,平台不单独裸售门票。'],
    ['二、担保出票',
        '平台承诺下单后 48 小时内完成出票,并上传实体票实拍照。如逾期未出票,用户可申请全额退款并获得额外补偿券。所有票源经核验与票权确认后交付。'],
    ['三、票品交付',
        '实体票支持顺丰保价寄送或现场当面交付两种方式。选择寄送的,请确保收货地址与联系方式准确;选择现场自取的,请凭订单凭证与身份证件到指定服务点领取。'],
    ['四、退改规则',
        '门票:演出前 7 天可全额退;前 3-7 天扣 20% 手续费;前 3 天内及演出结束后不支持退票。酒店:入住前 24 小时可免费取消。退款原路返回,1-5 个工作日到账。'],
    ['五、实名与入场',
        '部分演出需实名购票及入场,用户须提供真实、准确的出行人证件信息。因用户提供信息有误导致无法入场的,平台不承担责任。'],
    ['六、免责与赔付',
        '因平台原因导致无法正常入场的,平台按 ¥500/票 即时赔付(单笔上限 ¥2,000)。因不可抗力(演出方取消/延期、政策变动等)导致的变动,平台协助办理退款或改期,不承担额外赔偿。'],
    ['七、隐私保护',
        '平台依据《隐私政策》收集与使用用户信息,仅用于订单履约与服务提供,不会向无关第三方泄露用户个人信息与证件资料。'],
    ['八、协议变更',
        '平台有权根据法律法规及业务调整对本协议进行更新,更新后将在应用内公示。用户继续使用即视为接受变更后的协议。'],
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
              Text('购票服务协议',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('穩飛 SureTix · 用户须知',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
            ]),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const Text('穩飛购票服务协议',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('生效日期:2026 年 8 月 1 日',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 20),
          ..._sections.map((s) => _section(s[0], s[1])),
          const SizedBox(height: 10),
          const Text('感谢你选择穩飛,祝你观演愉快。',
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
