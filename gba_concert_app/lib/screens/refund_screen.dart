import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 退款 / 售后申请 —— 选项目 + 原因 + 规则 + 提交。后端接口预留。
class RefundScreen extends StatefulWidget {
  final String show;
  final String orderNo;
  const RefundScreen({
    super.key,
    this.show = '周杰伦 嘉年华巡演',
    this.orderNo = 'ST202608291',
  });

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final Set<int> _items = {0}; // 选中的退款项
  int _reason = -1;

  // 可退项 [名称, 金额, 说明]
  static const _refundItems = [
    ['门票 · 内场企位 × 2', 4360, '演出前 7 天可申请'],
    ['酒店 · 尖沙咀凯悦 2 晚', 2000, '入住前 24h 免费取消'],
  ];
  static const _reasons = [
    '行程有变,无法观演',
    '买错场次 / 票档',
    '重复购买',
    '对座位不满意',
    '其他原因',
  ];

  int get _refundTotal => _items.fold(
      0, (s, i) => s + (_refundItems[i][1] as int));

  bool get _canSubmit => _items.isNotEmpty && _reason >= 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('申请退款 / 售后',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _orderHead(),
              _sectionLabel('选择退款项目'),
              ..._refundItems.asMap().entries.map((e) => _itemCard(e.key)),
              _sectionLabel('退款原因'),
              _reasonList(),
              const SizedBox(height: 12),
              _rules(),
            ],
          ),
        ),
        _bottomBar(),
      ]),
    );
  }

  Widget _orderHead() => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          const Icon(LucideIcons.receipt, size: 16, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.show,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('订单号 ${widget.orderNo}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ]),
          ),
        ]),
      );

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
        child: Text(t,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      );

  Widget _itemCard(int i) {
    final e = _refundItems[i];
    final on = _items.contains(i);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: () => setState(() {
          if (on) {
            _items.remove(i);
          } else {
            _items.add(i);
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: on ? AppColors.amber : AppColors.cardBorder,
                  width: on ? 1.5 : 1)),
          child: Row(children: [
            Icon(on ? LucideIcons.squareCheckBig : LucideIcons.square,
                size: 18, color: on ? AppColors.amber : AppColors.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e[0] as String,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(e[2] as String,
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.textTertiary)),
                  ]),
            ),
            Text('¥${e[1]}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ]),
        ),
      ),
    );
  }

  Widget _reasonList() => Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(
            children: List.generate(_reasons.length, (i) {
          final on = _reason == i;
          return PressableScale(
            onTap: () => setState(() => _reason = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: i < _reasons.length - 1
                              ? AppColors.line
                              : Colors.transparent))),
              child: Row(children: [
                Expanded(
                  child: Text(_reasons[i],
                      style: TextStyle(
                          fontSize: 13,
                          color: on
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                ),
                Icon(on ? LucideIcons.circleCheck : LucideIcons.circle,
                    size: 17,
                    color: on ? AppColors.amber : AppColors.textFaint),
              ]),
            ),
          );
        })),
      );

  Widget _rules() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.deal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.deal.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Row(children: [
            Icon(LucideIcons.triangleAlert, size: 14, color: AppColors.deal),
            SizedBox(width: 8),
            Text('退款规则',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deal)),
          ]),
          SizedBox(height: 8),
          Text('· 演出前 7 天申请:门票全额退\n· 前 3-7 天:扣 20% 手续费\n· 前 3 天内及演出后:不支持退票\n· 酒店入住前 24h 可免费取消\n退款原路返回,1-5 个工作日到账。',
              style: TextStyle(
                  fontSize: 11, height: 1.7, color: AppColors.textSecondary)),
        ]),
      );

  Widget _bottomBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
              color: AppColors.bgElevate,
              border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('预计退款',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textTertiary)),
                  Text('¥$_refundTotal',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                ]),
            const Spacer(),
            PressableScale(
              onTap: _canSubmit ? () => _submit() : null,
              child: Opacity(
                opacity: _canSubmit ? 1 : 0.45,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      borderRadius: BorderRadius.circular(24)),
                  child: const Text('提交申请',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amberInk)),
                ),
              ),
            ),
          ]),
        ),
      );

  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('申请已提交',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: const Text('退款申请已提交,我们将在 24 小时内审核,结果通过消息通知你。',
            style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('知道了', style: TextStyle(color: AppColors.amber)),
          ),
        ],
      ),
    );
  }
}
