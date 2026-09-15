import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 选座结果 —— 返回给套餐页，继续走「酒店推荐」步骤。
class SeatPick {
  final Set<String> seats; // 占位:一个票品视作 1 张
  final String seatLabel; // 票品描述,如 "A区看台 30排 · 60座内"
  final int unitPrice; // 该票品单价
  final int total; // 合计(此处=单价×1)
  const SeatPick(this.seats, this.seatLabel, this.unitPrice, this.total);
}

/// 区域内票品列表页 —— 上一页已选好区域(票档)，进入后在该区域内挑具体票品。
/// 大麦「找票品」样式：列出该区域下不同排/位置的票品，各带单价、认证商家、出票预计。
/// 单击「购买」即选定该票品并返回，继续下一步。
class SeatSelectScreen extends StatefulWidget {
  final String show;
  final String session;
  final String venue;
  final String areaName; // 已选区域名，例如「A区看台」
  final int unitPrice; // 该区域基准单价

  const SeatSelectScreen({
    super.key,
    this.show = '周杰伦 嘉年华巡演',
    this.session = '2026/08/29 周五 · 20:00',
    this.venue = '香港 · 启德体育园主场馆',
    this.areaName = 'A区看台',
    this.unitPrice = 2180,
  });

  @override
  State<SeatSelectScreen> createState() => _SeatSelectScreenState();
}

/// 单个票品 [排位描述, 座位说明, 价格浮动(相对基准), 出票预计, 是否随机座]
class _Ticket {
  final String rowDesc;
  final String seatNote;
  final int priceDelta;
  final String eta;
  final bool random;
  const _Ticket(
      this.rowDesc, this.seatNote, this.priceDelta, this.eta, this.random);
}

class _SeatSelectScreenState extends State<SeatSelectScreen> {
  // 该区域下可售票品(参考大麦：同区多排、价格小幅浮动、出票时间不一)
  static const _tickets = [
    _Ticket('随机座位', '系统分配 · 尽量连座', -80, '预计开演前 3–5 天出票', true),
    _Ticket('30 排', '60 座内', 0, '预计开演前 1–2 天出票', false),
    _Ticket('26 排', '60 座内', 12, '预计开演当天出票', false),
    _Ticket('22 排', '30 座内', 40, '预计开演前 1–2 天出票', false),
    _Ticket('18 排', '30 座内', 88, '预计开演前 2–3 天出票', false),
    _Ticket('12 排', '前排优质视野', 160, '预计开演前 3–5 天出票', false),
    _Ticket('8 排', '黄金视野 · 靠近舞台', 260, '预计开演前 3–5 天出票', false),
  ];

  int _price(int i) => widget.unitPrice + _tickets[i].priceDelta;

  void _buy(int i) {
    final t = _tickets[i];
    final desc = t.random
        ? '${widget.areaName} · 随机座位'
        : '${widget.areaName} ${t.rowDesc} · ${t.seatNote}';
    final price = _price(i);
    Navigator.of(context).pop(
      SeatPick({'ticket-$i'}, desc, price, price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text('${widget.areaName} · 选择票品',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        _sessionBar(),
        _resultHint(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
            itemCount: _tickets.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, thickness: 1, color: AppColors.line, indent: 22, endIndent: 22),
            itemBuilder: (_, i) => _ticketRow(i),
          ),
        ),
      ]),
    );
  }

  Widget _sessionBar() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
        child: Row(children: [
          const Icon(LucideIcons.calendarDays, size: 14, color: AppColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.session,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
        ]),
      );

  Widget _resultHint() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
        child: Row(children: [
          Text('找到 ${_tickets.length} 个票品',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const Spacer(),
          const Text('低价优先',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amber)),
          const SizedBox(width: 14),
          const Text('出票最快',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ]),
      );

  Widget _ticketRow(int i) {
    final t = _tickets[i];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 左侧色条
        Container(
          width: 4,
          height: 58,
          margin: const EdgeInsets.only(right: 14, top: 2),
          decoration: BoxDecoration(
              gradient: AppColors.amberGradient,
              borderRadius: BorderRadius.circular(2)),
        ),
        // 中间信息
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                      t.random
                          ? widget.areaName
                          : '${widget.areaName} ${t.rowDesc}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 4),
                Text(t.random ? '随机座位' : t.seatNote,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(LucideIcons.badgeCheck,
                      size: 12, color: AppColors.green),
                  const SizedBox(width: 4),
                  const Text('认证商家',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 10, color: AppColors.line),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(t.eta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.green)),
                  ),
                ]),
              ]),
        ),
        const SizedBox(width: 12),
        // 右侧价格 + 购买
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('¥',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber)),
                Text('${_price(i)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber)),
                const Text(' /张',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
              ]),
          const SizedBox(height: 8),
          AmberButton(
            '购买',
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            onTap: () => _buy(i),
          ),
        ]),
      ]),
    );
  }
}
