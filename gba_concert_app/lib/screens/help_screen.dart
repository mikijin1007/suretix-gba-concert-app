import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 帮助中心 —— 分类折叠 FAQ。
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _open; // 当前展开项(全局索引)

  // [分类, 问题, 答案]
  static const _faqs = [
    ['购票', '什么是套餐?为什么不能只买票?', '穩飛为合规经营,门票需与住宿或权益礼包打包售卖。你可选「酒店套餐」或「观演礼包」,不额外裸卖单票。'],
    ['购票', '价格是怎么算的?', '套餐一价全含(门票+酒店/礼包),下单页实时计算,不拆单价。演出日周边酒店有溢价,系统按入住日自动核算。'],
    ['出票', '下单后多久出票?', '担保出票,下单后 48 小时内完成出票,出票即上传实体票实拍照,你可在订单里查看。'],
    ['出票', '怎么确认票是真的?', '每张票经票源核验与票权确认后交付,并上传实体票实拍照(含票面座位与防伪),假一赔十。'],
    ['退改', '可以退票吗?', '演出前 7 天可全额退门票,前 3-7 天扣 20% 手续费,前 3 天内及演出后不支持退票。酒店入住前 24h 可免费取消。'],
    ['退改', '怎么申请退款?', '进入「订单详情 → 申请售后」,选择退款项目与原因提交,审核通过后原路退回,1-5 个工作日到账。'],
    ['酒店', '酒店含早餐吗?', '所有套餐均含房型升级 + 双份早餐,具体房型以下单页所选为准。'],
    ['现场', '到现场票有问题怎么办?', '进入「订单详情 → 现场应急」,出示应急凭证并一键联系现场客服,后台核验后引导人工通道入场。'],
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
              Text('帮助中心',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('购票 · 出票 · 退改 · 现场',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
            ]),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          _searchHint(),
          const SizedBox(height: 8),
          ..._buildGrouped(),
        ],
      ),
    );
  }

  Widget _searchHint() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: const [
          Icon(LucideIcons.circleHelp, size: 16, color: AppColors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Text('没找到答案?点「我的 → 在线客服」7×24 人工解答。',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ]),
      );

  List<Widget> _buildGrouped() {
    final widgets = <Widget>[];
    String? lastCat;
    for (var i = 0; i < _faqs.length; i++) {
      final cat = _faqs[i][0];
      if (cat != lastCat) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
          child: Text(cat,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800)),
        ));
        lastCat = cat;
      }
      widgets.add(_item(i));
    }
    return widgets;
  }

  Widget _item(int i) {
    final open = _open == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: () => setState(() => _open = open ? null : i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: open ? AppColors.amber.withValues(alpha: 0.5) : AppColors.cardBorder)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(_faqs[i][1],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Icon(open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 16, color: AppColors.textTertiary),
                ]),
                if (open) ...[
                  const SizedBox(height: 10),
                  Text(_faqs[i][2],
                      style: const TextStyle(
                          fontSize: 12, height: 1.6, color: AppColors.textSecondary)),
                ],
              ]),
        ),
      ),
    );
  }
}
