import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ticket_stub_screen.dart';
import 'hotel_booking_screen.dart';
import 'refund_screen.dart';
import 'emergency_screen.dart';

/// 订单详情 —— 票/酒店/加购各项独立状态 + 看电子票根
class OrderDetailScreen extends StatelessWidget {
  final String show;
  final String session;
  final String summary;
  final int status; // 0待出票 1待观演 2已完成
  final int posterSeed;
  final int total;

  const OrderDetailScreen({
    super.key,
    required this.show,
    required this.session,
    required this.summary,
    required this.status,
    required this.posterSeed,
    required this.total,
  });

  bool get _issued => status >= 1; // 待观演/已完成=已出票

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('订单详情',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          _statusHero(),
          const SizedBox(height: 16),
          _sectionTitle('履约进度 · 各项独立'),
          _itemTrack(LucideIcons.ticket, '门票',
              _issued ? '已出票 · 实体票已上传' : '出票中 · 48h 内', _issued,
              onTap: () => AppRoute.to(
                  context,
                  TicketStubScreen(
                    show: show,
                    session: session,
                    seat: summary,
                    posterSeed: posterSeed,
                    issued: _issued,
                  ))),
          _itemTrack(LucideIcons.bedDouble, '酒店',
              '已确认 · 尖沙咀凯悦 豪华海景房 2 晚', true,
              onTap: () =>
                  AppRoute.to(context, const HotelBookingScreen())),
          _itemTrack(LucideIcons.train, '跨境交通', '未购买', false, muted: true),
          const SizedBox(height: 8),
          if (_issued) _ticketEntry(context),
          const SizedBox(height: 16),
          _sectionTitle('订单信息'),
          _infoCard(),
          const SizedBox(height: 16),
          _guaranteeBar(),
          const SizedBox(height: 16),
          _actions(),
        ],
      ),
    );
  }

  static const _statusText = ['待出票', '待观演', '已完成'];
  static const _statusColor = [AppColors.deal, AppColors.amber, AppColors.green];

  Widget _statusHero() => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 150,
            child: Stack(fit: StackFit.expand, children: [
              PosterBox(seed: posterSeed),
              DecoratedBox(decoration: BoxDecoration(gradient: AppColors.scrim())),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: (_statusColor[status]).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(_statusText[status],
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1200))),
                      ),
                      const SizedBox(height: 8),
                      Text(show, style: AppTheme.displaySerif(size: 20)),
                      const SizedBox(height: 4),
                      Text(session,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFCFCFCF))),
                    ]),
              ),
            ]),
          ),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );

  Widget _itemTrack(IconData icon, String name, String status, bool done,
          {bool muted = false, VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: muted
                    ? AppColors.bgElevate
                    : const Color(0x24E5477B),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon,
                size: 17,
                color: muted ? AppColors.textFaint : AppColors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: muted
                              ? AppColors.textTertiary
                              : AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(status,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ]),
          ),
          // 可点入的项目显示箭头，否则保留状态图标
          if (onTap != null) ...[
            if (done)
              const Icon(LucideIcons.circleCheckBig,
                  size: 15, color: AppColors.green),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textFaint),
          ] else
            Icon(
                done
                    ? LucideIcons.circleCheckBig
                    : (muted ? LucideIcons.circleOff : LucideIcons.clock),
                size: 18,
                color: done
                    ? AppColors.green
                    : (muted ? AppColors.textFaint : AppColors.deal)),
        ]),
        ),
      );

  Widget _ticketEntry(BuildContext context) => PressableScale(
        onTap: () => AppRoute.to(
            context,
            TicketStubScreen(
              show: show,
              session: session,
              posterSeed: posterSeed,
              issued: true,
            )),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0x2EE5477B), Color(0x0AE5477B)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x66E5477B))),
          child: Row(children: const [
            Icon(LucideIcons.ticketCheck, size: 20, color: AppColors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('查看电子票根',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('留念 / 分享朋友圈 · 凭实体票入场',
                        style: TextStyle(
                            fontSize: 10.5, color: AppColors.textTertiary)),
                  ]),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: AppColors.amber),
          ]),
        ),
      );

  Widget _infoCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          _kv('套餐内容', summary),
          _kv('订单号', 'SF20260829X1206'),
          _kv('下单时间', '2026/08/12 19:10'),
          _kv('交货方式', '顺丰快递到家'),
          _kv('应付总额', '¥$total', vColor: AppColors.amber, strong: true),
        ]),
      );

  Widget _kv(String k, String v, {Color? vColor, bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 72,
              child: Text(k,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(v,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
                    color: vColor ?? AppColors.textPrimary)),
          ),
        ]),
      );

  Widget _guaranteeBar() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x3DE5477B))),
        child: Row(children: const [
          Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text('担保出票 · 验票保真 · 现场无法入场 ¥500/票赔付',
                style: TextStyle(fontSize: 11.5, color: AppColors.amberSoft)),
          ),
        ]),
      );

  Widget _actions() => Builder(
      builder: (context) => Column(children: [
        // 待观演时置顶「现场应急」入口(观演当天最需要)
        if (status == 1) ...[
          PressableScale(
            onTap: () => AppRoute.to(
                context, EmergencyScreen(show: show, orderNo: 'ST202608291')),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                  gradient: AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(24)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(LucideIcons.shieldAlert, size: 16, color: AppColors.amberInk),
                SizedBox(width: 6),
                Text('现场应急 · 到场遇问题点这里',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberInk)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(children: [
          Expanded(
            child: PressableScale(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder)),
                child: const Center(
                  child: Text('联系客服',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PressableScale(
              onTap: () => AppRoute.to(
                  context, RefundScreen(show: show, orderNo: 'ST202608291')),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                    color: const Color(0x22FF4D4D),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x55FF4D4D))),
                child: const Center(
                  child: Text('申请售后',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF6B6B))),
                ),
              ),
            ),
          ),
        ]),
      ]));
}
