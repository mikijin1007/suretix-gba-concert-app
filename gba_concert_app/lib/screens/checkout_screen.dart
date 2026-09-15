import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ticket_stub_screen.dart';

/// 独立下单确认页 —— 8块逐项确认 + 出行人/收货表单 + 交货方式
/// 暗金皮，信任建设(平台保障 + 不连座提醒)
class CheckoutScreen extends StatefulWidget {
  final String show;
  final String session;
  final String venue;
  final String ticketDesc; // 票档/座位描述
  final bool seatMode; // true=按座位(确定) false=按票档(可能不连座)
  final bool hasBundle; // 是否含捆绑项(酒店/礼包)，取消选择后为 false
  final bool bundleIsHotel; // true=酒店套餐 false=观演礼包(合规捆绑二选一)
  final String hotel;
  final int hotelStar;
  final String room;
  final int nights;
  final String giftName; // 礼包名(bundleIsHotel=false 时用)
  final int giftValue; // 礼包权益面值加总
  final List<String> giftPerks; // 礼包权益列表
  final bool transport;
  final int total;

  const CheckoutScreen({
    super.key,
    this.show = '周杰伦 嘉年华巡演',
    this.session = '2026/08/29 周五 20:00',
    this.venue = '香港 · 启德体育园主场馆',
    this.ticketDesc = '内场企位 × 2',
    this.seatMode = false,
    this.hasBundle = true,
    this.bundleIsHotel = true,
    this.hotel = '尖沙咀凯悦',
    this.hotelStar = 5,
    this.room = '豪华海景房（升级）+ 双早',
    this.nights = 2,
    this.giftName = '观演礼包 · 基础',
    this.giftValue = 800,
    this.giftPerks = const [],
    this.transport = false,
    this.total = 6360,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _delivery = 0; // 0=顺丰快递(+¥20) 1=现场自取(免费)
  bool _agree = false;
  static const _shipFee = 20;

  // 支付倒计时锁票(Ticketmaster/大麦模式):15 分钟内不支付则释放座位
  Timer? _timer;
  int _remain = 15 * 60; // 秒

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remain <= 0) {
        t.cancel();
        return;
      }
      setState(() => _remain--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _remainText {
    final m = (_remain ~/ 60).toString().padLeft(2, '0');
    final s = (_remain % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _grandTotal => widget.total + (_delivery == 0 ? _shipFee : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('确认订单',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
            children: [
              _showBlock(),
              _ticketBlock(),
              if (widget.hasBundle)
                (widget.bundleIsHotel ? _hotelBlock() : _giftBlock()),
              _guaranteeBlock(),
              _travelerBlock(),
              _deliveryBlock(),
              if (_delivery == 0) _addressBlock(),
              _agreeBlock(),
            ],
          ),
        ),
        _bottomBar(),
      ]),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
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
                  Icon(icon, size: 16, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                ...children,
              ]),
        ),
      );

  Widget _kv(String k, String v, {Color? vColor, bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 64,
              child: Text(k,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(v,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                    color: vColor ?? AppColors.textPrimary)),
          ),
        ]),
      );

  // ① 演出
  // 支付倒计时锁票条(Ticketmaster/大麦模式:座位已锁,15分钟内支付)
  Widget _lockBar() {
    final urgent = _remain <= 3 * 60;
    final expired = _remain <= 0;
    final accent = expired
        ? AppColors.textFaint
        : (urgent ? AppColors.deal : AppColors.green);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.4))),
        child: Row(children: [
          Icon(expired ? LucideIcons.circleX : LucideIcons.lockKeyhole,
              size: 16, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                expired
                    ? '座位锁定已超时,请返回重新选择'
                    : (urgent ? '座位即将释放,请尽快完成支付' : '座位已为你锁定,请在时限内完成支付'),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: expired ? AppColors.textSecondary : AppColors.textPrimary)),
          ),
          if (!expired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(_remainText,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _showBlock() => _sectionCard('演出信息', LucideIcons.music, [
        _kv('演出', widget.show, strong: true),
        _kv('场次', widget.session),
        _kv('场馆', widget.venue),
      ]);

  // ② 座位/票档 + 不连座提醒
  Widget _ticketBlock() => _sectionCard('门票', LucideIcons.ticket, [
        _kv('票档', widget.ticketDesc, strong: true),
        if (widget.seatMode)
          _kv('座位', '已选具体座位', vColor: AppColors.green)
        else
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0x22FF785A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x55FF785A))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Icon(LucideIcons.triangleAlert, size: 14, color: AppColors.deal),
              SizedBox(width: 8),
              Expanded(
                child: Text('按票档为系统分配座位，多张将优先安排连座，但热门场次可能无法保证完全相邻，敬请知悉。',
                    style: TextStyle(
                        fontSize: 11, height: 1.5, color: Color(0xFFE0A58A))),
              ),
            ]),
          ),
      ]);

  // ③ 酒店
  Widget _hotelBlock() => _sectionCard('酒店住宿', LucideIcons.bedDouble, [
        Row(children: [
          Text(widget.hotel,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Row(
              children: List.generate(
                  widget.hotelStar,
                  (_) => const Icon(LucideIcons.star,
                      size: 10, color: AppColors.amber))),
        ]),
        const SizedBox(height: 8),
        _kv('房型', widget.room, vColor: AppColors.amber),
        _kv('入住', '08/29 – 08/${29 + widget.nights} · 共 ${widget.nights} 晚'),
      ]);

  // ③ 观演礼包(不选酒店时的合规捆绑物)
  Widget _giftBlock() => _sectionCard('观演礼包', LucideIcons.gift, [
        Row(children: [
          Text(widget.giftName,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0x1F4EC38A),
                borderRadius: BorderRadius.circular(8)),
            child: Text('含¥${widget.giftValue}权益',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green)),
          ),
        ]),
        const SizedBox(height: 12),
        ...widget.giftPerks.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                const Icon(LucideIcons.ticket,
                    size: 12, color: AppColors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
              ]),
            )),
      ]);

  // ④ 平台保障
  Widget _guaranteeBlock() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3DE5477B))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.amber),
              SizedBox(width: 8),
              Text('穩飛保障',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            _guardLine('担保出票', '48 小时内出票，出票即上传实体票实拍照'),
            _guardLine('验票保真', '核验票源与票权后交付，杜绝假票'),
            _guardLine('现场兜底', '无法入场按 ¥500/票赔付（单笔上限 ¥2,000）'),
          ]),
        ),
      );

  Widget _guardLine(String t, String d) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.check, size: 13, color: AppColors.amber),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
                text: TextSpan(
                    text: '$t  ',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    children: [
                  TextSpan(
                      text: d,
                      style: const TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary))
                ])),
          ),
        ]),
      );

  // ⑤ 出行人
  Widget _travelerBlock() => _sectionCard('出行人 / 联系人', LucideIcons.user, [
        _field('姓名', '请输入姓名'),
        const SizedBox(height: 10),
        _field('手机号', '接收出票通知', keyboard: TextInputType.phone),
      ]);

  Widget _field(String label, String hint,
          {TextInputType? keyboard}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 12.5, color: AppColors.textFaint),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.bgElevate,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cardBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.amber)),
          ),
        ),
      ]);

  // ⑥ 交货方式
  Widget _deliveryBlock() => _sectionCard('交货方式', LucideIcons.package, [
        _deliveryOption(0, LucideIcons.truck, '顺丰快递到家', '纸质票寄送 · 预计 2–3 天', '+¥$_shipFee'),
        const SizedBox(height: 10),
        _deliveryOption(1, LucideIcons.mapPin, '现场自取 / 当面交票', '演出当天场馆附近领取', '免费'),
      ]);

  Widget _deliveryOption(
          int idx, IconData icon, String title, String sub, String price) =>
      PressableScale(
        onTap: () => setState(() => _delivery = idx),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _delivery == idx
                  ? const Color(0x1FE5477B)
                  : AppColors.bgElevate,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _delivery == idx
                      ? const Color(0x99E5477B)
                      : AppColors.cardBorder,
                  width: _delivery == idx ? 1.5 : 1)),
          child: Row(children: [
            Icon(_delivery == idx ? LucideIcons.circleCheckBig : LucideIcons.circle,
                size: 18,
                color: _delivery == idx ? AppColors.amber : AppColors.textFaint),
            const SizedBox(width: 10),
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(sub,
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.textTertiary)),
                  ]),
            ),
            Text(price,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: price == '免费'
                        ? AppColors.green
                        : AppColors.amber)),
          ]),
        ),
      );

  // ⑦ 收货地址（顺丰才显示）
  Widget _addressBlock() => _sectionCard('收货地址', LucideIcons.mapPinHouse, [
        _field('收货人', '请输入收货人姓名'),
        const SizedBox(height: 10),
        _field('联系电话', '收件电话', keyboard: TextInputType.phone),
        const SizedBox(height: 10),
        _field('详细地址', '省 / 市 / 区 街道门牌'),
      ]);

  // ⑧ 同意条款
  Widget _agreeBlock() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: PressableScale(
          onTap: () => setState(() => _agree = !_agree),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(_agree ? LucideIcons.squareCheckBig : LucideIcons.square,
                size: 18, color: _agree ? AppColors.amber : AppColors.textFaint),
            const SizedBox(width: 8),
            const Expanded(
              child: Text.rich(TextSpan(
                  text: '我已阅读并同意 ',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                        text: '《购票服务协议》《担保与退改规则》',
                        style: TextStyle(color: AppColors.amber)),
                  ])),
            ),
          ]),
        ),
      );

  Widget _bottomBar() => Container(
        decoration: const BoxDecoration(
          color: Color(0xF2101012),
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        child: Row(children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('应付总额',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                RichText(
                    text: TextSpan(
                        text: '¥$_grandTotal',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber),
                        children: [
                      if (_delivery == 0)
                        const TextSpan(
                            text: ' 含运费',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textTertiary))
                    ])),
              ]),
          const Spacer(),
          Opacity(
            opacity: _agree ? 1 : 0.5,
            child: AmberButton('确认支付',
                onTap: _agree
                    ? () => AppRoute.to(
                        context,
                        TicketStubScreen(
                          paidSuccess: true,
                          show: widget.show,
                          session: widget.session,
                          venue: widget.venue,
                          seat: widget.ticketDesc,
                        ))
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14)),
          ),
        ]),
      );
}
