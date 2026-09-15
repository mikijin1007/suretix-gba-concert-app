import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

/// 订单中心 —— 管理全部订单(票+酒店+加购)。状态:全部/待出票/待观演/已完成
class OrderCenterScreen extends StatefulWidget {
  const OrderCenterScreen({super.key});

  @override
  State<OrderCenterScreen> createState() => _OrderCenterScreenState();
}

class _OrderCenterScreenState extends State<OrderCenterScreen> {
  int _tab = 0;
  static const _tabs = ['全部', '待出票', '待观演', '已完成'];

  // [演出, 场次, 套餐概览, 状态(0待出票 1待观演 2已完成), 图seed, 金额]
  static const _orders = [
    ['周杰伦 嘉年华巡演', '08/29 周五 20:00', '内场企位×2 · 尖沙咀凯悦2晚', 0, 0, 6360],
    ['MIRROR 演唱会', '09/07 亚博馆', 'A区×2 · 红磡海景2晚', 1, 3, 5180],
    ['林俊杰 JJ20', '06/14 亚博馆', 'B区×1 · 旺角智选1晚', 2, 2, 2480],
  ];

  List<List<Object>> get _filtered {
    if (_tab == 0) return _orders.map((e) => e).toList();
    final s = _tab - 1; // 0待出票 1待观演 2已完成
    return _orders.where((o) => o[3] == s).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(),
          _tabBar(),
          Expanded(
            child: _filtered.isEmpty
                ? _empty()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 100),
                    children: [
                      ..._filtered.map((o) => _orderCard(o)),
                      _brandFooter(),
                    ],
                  ),
          ),
        ]),
      ),
    );
  }

  // 头部：大标题 + 信任细条(与观演套餐页一致)
  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        child: Row(children: [
          if (Navigator.of(context).canPop()) ...[
            const AppBackButton(),
            const SizedBox(width: 6),
          ],
          const Text('我的订单',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const Spacer(),
          Row(children: const [
            Icon(LucideIcons.shieldCheck, size: 13, color: AppColors.amber),
            SizedBox(width: 4),
            Text('12.8万张已出票 · 0违约',
                style: TextStyle(fontSize: 10.5, color: AppColors.amberSoft)),
          ]),
        ]),
      );

  // 列表底部品牌 logo 水印
  Widget _brandFooter() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 24),
        child: Center(
          child: Opacity(
            opacity: 0.18,
            child: Image.asset('assets/images/logo_watermark.png',
                width: 150, fit: BoxFit.contain),
          ),
        ),
      );

  Widget _tabBar() => Container(
        height: 44,
        margin: const EdgeInsets.only(bottom: 4),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final on = _tab == i;
            return Center(
              child: PressableScale(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                      gradient: on ? AppColors.amberGradient : null,
                      color: on ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: on
                          ? null
                          : Border.all(color: AppColors.cardBorder)),
                  child: Text(_tabs[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: on
                              ? AppColors.amberInk
                              : AppColors.textSecondary)),
                ),
              ),
            );
          },
        ),
      );

  Widget _empty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.receiptText, size: 44, color: AppColors.textFaint),
          SizedBox(height: 12),
          Text('暂无相关订单',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
        ]),
      );

  static const _statusMeta = [
    ['待出票', AppColors.deal],
    ['待观演', AppColors.amber],
    ['已完成', AppColors.green],
  ];

  Widget _orderCard(List<Object> o) {
    final status = o[3] as int;
    final meta = _statusMeta[status];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: PressableScale(
        onTap: () => AppRoute.to(
            context,
            OrderDetailScreen(
              show: o[0] as String,
              session: o[1] as String,
              summary: o[2] as String,
              status: status,
              posterSeed: o[4] as int,
              total: o[5] as int,
            )),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            // 顶部：状态条
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: (meta[1] as Color).withValues(alpha: 0.12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17))),
              child: Row(children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: meta[1] as Color, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text(meta[0] as String,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: meta[1] as Color)),
                const Spacer(),
                Text('订单详情',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
                const Icon(LucideIcons.chevronRight,
                    size: 13, color: AppColors.textTertiary),
              ]),
            ),
            // 主体
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                PosterBox(
                    width: 60,
                    height: 78,
                    seed: o[4] as int,
                    radius: BorderRadius.circular(12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o[0] as String,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(o[1] as String,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textTertiary)),
                        const SizedBox(height: 8),
                        // 多项 chip
                        Wrap(spacing: 6, runSpacing: 6, children: const [
                          _ItemChip(LucideIcons.ticket, '门票'),
                          _ItemChip(LucideIcons.bedDouble, '酒店'),
                        ]),
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('¥${o[5]}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                  const SizedBox(height: 2),
                  Text(o[2] as String,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textFaint)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ItemChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.bgElevate, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.amber),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}
