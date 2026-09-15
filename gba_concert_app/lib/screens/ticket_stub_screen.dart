import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/souvenir_ticket.dart';

/// 电子票根 —— 撕票根造型仪式感留念(非入场凭证) + 出票实拍 + 分享
/// 香港演出为实体票，此电子票仅作留念/分享，凭实体票入场。
class TicketStubScreen extends StatelessWidget {
  final bool paidSuccess; // true=支付成功后展示(带成功头) false=票夹进入
  final String show;
  final String session;
  final String venue;
  final String seat;
  final String orderNo;
  final int posterSeed;
  final bool issued; // 是否已出票(出票实拍是否可见)

  const TicketStubScreen({
    super.key,
    this.paidSuccess = false,
    this.show = '周杰伦 嘉年华巡演',
    this.session = '2026/08/29 周五 20:00',
    this.venue = '启德体育园主场馆',
    this.seat = '内场企位 × 2',
    this.orderNo = 'SF20260829X1206',
    this.posterSeed = 0,
    this.issued = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(paidSuccess ? '支付成功' : '纪念票',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          if (paidSuccess)
            _successHead()
                .animate()
                .fadeIn(duration: 300.ms)
                .scaleXY(begin: 0.8, end: 1.0, duration: 420.ms, curve: Curves.easeOutBack),
          // 未出票：只显示「待出票 · 耐心等待」，不展示票根与分享
          if (!issued)
            _pendingOnly()
          else ...[
            // 电子纪念票(大麦样式)：海报 + 全息印章 + 齿孔撕线 + 限量编号
            paidSuccess
                ? _souvenir()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: 520.ms,
                        delay: 200.ms,
                        curve: Curves.easeOutBack)
                : _souvenir(),
            const SizedBox(height: 16),
            _shareBar(context),
          ],
        ],
      ),
    );
  }

  Widget _successHead() => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                gradient: AppColors.amberGradient, shape: BoxShape.circle),
            child: const Icon(LucideIcons.check,
                size: 30, color: AppColors.amberInk),
          ),
          const SizedBox(height: 12),
          const Text('下单成功 · 穩出票',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('48 小时内出票，出票即上传实体票实拍照',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      );

  // 撕票根
  Widget _stub() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33E5477B),
                blurRadius: 28,
                offset: Offset(0, 10))
          ],
        ),
        child: Column(children: [
          // 上半：海报 + 艺人头 + 演出名
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 168,
              child: Stack(fit: StackFit.expand, children: [
                PosterBox(seed: posterSeed),
                DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.scrim())),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0x99000000),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('电子留念票',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  right: 16,
                  child: Row(children: [
                    ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: PosterBox(seed: posterSeed),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(show, style: AppTheme.displaySerif(size: 18)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          // 齿孔撕线
          _perfLine(),
          // 下半：字段网格 + 条形码
          Container(
            decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20))),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(children: [
              Row(children: [
                Expanded(child: _field('日期', session.split(' ')[0])),
                Expanded(child: _field('时间', session.split(' ').last)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field('场馆', venue)),
                Expanded(child: _field('座位', seat)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field('订单号', orderNo)),
              ]),
              const SizedBox(height: 16),
              // 条形码(仪式感,非入场凭证)
              Container(
                height: 54,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                child: CustomPaint(
                    size: const Size(double.infinity, 54),
                    painter: _BarcodePainter()),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(LucideIcons.info, size: 12, color: AppColors.textFaint),
                SizedBox(width: 5),
                Text('电子留念票 · 请凭实体票入场',
                    style: TextStyle(fontSize: 10.5, color: AppColors.textFaint)),
              ]),
            ]),
          ),
        ]),
      );

  Widget _field(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          const SizedBox(height: 3),
          Text(v,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _perfLine() => SizedBox(
        height: 22,
        child: Stack(children: [
          Container(color: AppColors.card),
          Positioned(
            left: -11,
            top: 0,
            child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: AppColors.bg, shape: BoxShape.circle)),
          ),
          Positioned(
            right: -11,
            top: 0,
            child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: AppColors.bg, shape: BoxShape.circle)),
          ),
          Positioned.fill(
            left: 16,
            right: 16,
            top: 10,
            child: CustomPaint(painter: _DashPainter()),
          ),
        ]),
      );

  // 电子纪念票卡
  Widget _souvenir() => SouvenirTicket(
        show: show,
        dateLine: '$session | $venue',
        qtyPrice: seat,
        serial: orderNo.length >= 6
            ? orderNo.substring(orderNo.length - 6)
            : '049029',
        posterSeed: posterSeed,
      );

  // 底部:转赠 / 实体纪念票 + 限量说明
  Widget _souvenirActions(BuildContext context) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _actionIcon(context, LucideIcons.heartHandshake, '转赠(剩1次)',
              badge: '会员专享',
              onTap: () => _snack(context, '转赠功能:每张纪念票可转赠 1 次')),
          const SizedBox(width: 42),
          _actionIcon(context, LucideIcons.package, '实体纪念票',
              badge: 'NEW',
              onTap: () => _snack(context, '可申请制作实体纪念票,顺丰包邮到家')),
        ]),
        const SizedBox(height: 16),
        const Text('穩飛电子纪念票 | 全国限量 50 万份 | 查看规则 >',
            style: TextStyle(fontSize: 10.5, color: AppColors.textFaint)),
      ]);

  Widget _actionIcon(BuildContext context, IconData icon, String label,
          {String? badge, VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Column(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder)),
              child: Icon(icon, size: 22, color: AppColors.amber),
            ),
            if (badge != null)
              Positioned(
                top: -6,
                right: -10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(badge,
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amberInk)),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
        ]),
      );

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  // 未出票：只显示「待出票 · 耐心等待」
  Widget _pendingOnly() => Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x3DE5477B))),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.14),
                shape: BoxShape.circle),
            child: const Icon(LucideIcons.clock,
                size: 30, color: AppColors.amber),
          ),
          const SizedBox(height: 18),
          const Text('待出票',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('请耐心等待',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Text('平台承诺 48 小时内完成出票,出票后会第一时间通知你',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, height: 1.6, color: AppColors.textTertiary)),
        ]),
      );

  // 出票实拍(商家上传实体票照)
  Widget _issuedProof() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x3DE5477B))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.amber),
            const SizedBox(width: 8),
            Text(issued ? '实体票已出票 · 实拍' : '出票中 · 预计 48h 内',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (issued)
              const Text('已上传',
                  style: TextStyle(fontSize: 11, color: AppColors.green)),
          ]),
          const SizedBox(height: 12),
          if (issued)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/poster_2.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.bgElevate)),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xB3000000),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('穩飛出票实拍 · 08/28 14:20',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.bgElevate,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('出票后将在此展示实体票实拍照',
                  style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
            ),
          const SizedBox(height: 10),
          const Text('真实票源 · 出票即拍照上传，让你安心，也可分享给同行朋友',
              style: TextStyle(
                  fontSize: 11, height: 1.5, color: AppColors.textSecondary)),
        ]),
      );

  Widget _shareBar(BuildContext context) => Row(children: [
        Expanded(
          child: PressableScale(
            onTap: paidSuccess
                ? () => Navigator.of(context)
                    .popUntil((r) => r.isFirst) // 回到 MainShell
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(paidSuccess ? LucideIcons.receipt : LucideIcons.download,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(paidSuccess ? '回到订单页' : '保存票根',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AmberButton('分享',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('海报已保存到我的图库'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  )),
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ]);

  // 炫酷分享卡弹层(带票信息+实体票实拍,方便宣传)
  void _openShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ShareSheet(
        show: show,
        session: session,
        venue: venue,
        seat: seat,
        posterSeed: posterSeed,
      ),
    );
  }
}

/// 条形码画笔(仪式感)
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE8E8E8);
    double x = 0;
    var seed = 7;
    while (x < size.width) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final w = 1.0 + (seed % 4);
      if ((seed >> 3) % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w + 1.5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 撕线虚线
class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.5;
    const dash = 5.0, gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 炫酷分享卡 —— 可晒朋友圈的观演卡(暗金+票信息+实拍+品牌水印)
class _ShareSheet extends StatelessWidget {
  final String show, session, venue, seat;
  final int posterSeed;
  const _ShareSheet({
    required this.show,
    required this.session,
    required this.venue,
    required this.seat,
    required this.posterSeed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0x55FFFFFF),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x66E5477B),
                      blurRadius: 40,
                      offset: Offset(0, 12))
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(children: [
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: PosterBox(seed: posterSeed),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xE6000000)],
                        stops: [0.2, 0.85],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                gradient: AppColors.amberGradient,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('我要去看现场',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amberInk)),
                          ),
                          const Spacer(),
                          const Text('穩飛 SURETIX',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.amber)),
                        ]),
                        const SizedBox(height: 14),
                        Text(show, style: AppTheme.displaySerif(size: 30)),
                        const SizedBox(height: 10),
                        _line(LucideIcons.calendar, session),
                        const SizedBox(height: 6),
                        _line(LucideIcons.mapPin, venue),
                        const SizedBox(height: 6),
                        _line(LucideIcons.ticket, seat),
                        const SizedBox(height: 16),
                        Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: Image.asset(
                                  'assets/images/poster_2.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const ColoredBox(
                                          color: AppColors.bgElevate)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('穩飛担保出票 · 实体票已上传\n扫码一起来看现场',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    height: 1.5,
                                    color: Color(0xFFCFCFCF))),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(LucideIcons.qrCode,
                                size: 40, color: Colors.black),
                          ),
                        ]),
                      ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
            _ShareChannel(LucideIcons.messageCircle, '微信'),
            _ShareChannel(LucideIcons.users, '朋友圈'),
            _ShareChannel(LucideIcons.share2, '小红书'),
            _ShareChannel(LucideIcons.download, '保存图片'),
          ]),
        ]),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: AppColors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE8E8E8))),
        ),
      ]);
}

class _ShareChannel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShareChannel(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder)),
          child: Icon(icon, size: 20, color: AppColors.amber),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}
