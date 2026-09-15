import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'package_builder_screen.dart';
import 'hotel_detail_screen.dart';

/// 演出详情介绍页 —— 纯介绍(不下单)。双 tab：演出 / 酒店。
/// 暗金皮 + 吸收 Mo Ticket 编辑排版(大图铺满+模块卡+票根CTA)。
class EventIntroScreen extends StatefulWidget {
  final String artist; // 主标题：艺人名
  final String subtitle; // 副标题：巡演名
  final String venueLine; // 顶部地点行
  final String dateText; // 演出时间
  final String venue; // 场馆名
  final int seed; // 海报图种子
  final bool showHotel; // 是否展示「酒店住宿」标签(仅套餐入口为 true)

  const EventIntroScreen({
    super.key,
    this.artist = '周杰伦',
    this.subtitle = '嘉年华世界巡回演唱会 2026',
    this.venueLine = '香港 · 启德体育园主场馆 · 8月29–31日',
    this.dateText = '2026/08/29–31 · 20:00',
    this.venue = '启德体育园主场馆',
    this.seed = 0,
    this.showHotel = false,
  });

  @override
  State<EventIntroScreen> createState() => _EventIntroScreenState();
}

class _EventIntroScreenState extends State<EventIntroScreen> {
  int _tab = 0; // 0=演出 1=酒店
  int _hotelSel = 0; // 酒店 tab 选中的酒店(动态驱动房型)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        // 全屏艺人大图(固定背景)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 460,
          child: Stack(fit: StackFit.expand, children: [
            KenBurns(child: PosterBox(seed: widget.seed)),
            DecoratedBox(decoration: BoxDecoration(gradient: AppColors.scrim())),
            Positioned(
              left: 22,
              right: 22,
              bottom: 92,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      _pill('SELLING FAST', const Color(0xCCFF785A),
                          Colors.white),
                      const SizedBox(width: 6),
                      _pill('官方售罄 · 我们仍有票', const Color(0x99000000),
                          AppColors.amber),
                    ]),
                    const SizedBox(height: 12),
                    Text(widget.artist, style: AppTheme.displaySerif(size: 42)),
                    Text(widget.subtitle,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.9))),
                  ]),
            ),
          ]),
        ),
        // 底部卡片上浮(可滚动，圆角顶盖住图片下半)
        ListView(
          padding: const EdgeInsets.only(top: 400, bottom: 170),
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.only(top: 8),
              child: Column(children: [
                // 顶部小横条
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(children: [
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(widget.venueLine,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary)),
                    ),
                  ]),
                ),
                _urgencyStrip(),
                // 套餐入口：演出信息 + 酒店住宿两个标签
                if (widget.showHotel) ...[
                  _tabBar(),
                  if (_tab == 0) ..._eventTab() else ..._hotelTab(),
                ] else ...[
                  const SizedBox(height: 8),
                  ..._eventTab(),
                ],
              ]),
            ),
          ],
        ),
        _topButtons(),
        _stickyBuy(),
      ]),
    );
  }

  Widget _pill(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x22FFFFFF))),
        child: Text(t,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      );

  Widget _topButtons() => Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: SafeArea(
          child: Row(children: [
            _circleBtn(LucideIcons.chevronLeft,
                () => Navigator.of(context).maybePop()),
            const Spacer(),
            _circleBtn(LucideIcons.heart, () {}),
            const SizedBox(width: 10),
            _circleBtn(LucideIcons.share2, () {}),
          ]),
        ),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => PressableScale(
        onTap: onTap,
        ensureHitArea: true,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
              color: Color(0xB3000000), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      );

  // ── 双 tab ──
  Widget _tabBar() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            _tabBtn('演出详情', LucideIcons.music, 0),
            _tabBtn('酒店住宿', LucideIcons.bedDouble, 1),
          ]),
        ),
      );

  Widget _tabBtn(String label, IconData icon, int idx) {
    final on = _tab == idx;
    return Expanded(
      child: PressableScale(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              gradient: on ? AppColors.amberGradient : null,
              borderRadius: BorderRadius.circular(11)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 15,
                color: on ? AppColors.amberInk : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: on ? AppColors.amberInk : AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  // ── 演出 tab（图文详细：海报/看点/曲目/阵容/往期/场馆/须知）──
  List<Widget> _eventTab() => [
        _infoStrip(),
        _sectionHead('演出海报'),
        _posterCard(),
        _sectionHead('演出看点'),
        _highlightGrid(),
        _sectionHead('关于演出'),
        _card(null, [
          const Text(
              '周杰伦「嘉年华」世界巡回演唱会睽违四年再度登陆香港，全新升级舞台与灯光设计，融合经典曲目回顾与新作首唱。启德体育园主场馆连开三场，360° 环形舞台让每个角度都是好视野，为歌迷带来沉浸式视听盛宴。',
              style: TextStyle(
                  fontSize: 13, height: 1.8, color: AppColors.textSecondary)),
        ]),
        _sectionHead('演出阵容'),
        _lineupRow('周杰伦', '主唱 · Headliner', 0),
        _lineupRow('神秘嘉宾', '特别演出 · 现场揭晓', 2),
        _sectionHead('真实购票评价'),
        _reviewWall(),
        _recentDeals(),
        _sectionHead('往期现场'),
        _pastGallery(),
        _sectionHead('场馆信息'),
        _venueCard(),
        _sectionHead('票品与配送'),
        _card(null, [
          _noticeLine('纸质票（不实名）· 支持转赠'),
          _noticeLine('配送方式：顺丰快递到家 / 现场当面交票'),
          _noticeLine('下单后 48 小时内出票，出票即上传实体票实拍照'),
        ]),
        _sectionHead('观演须知'),
        _card(null, [
          _noticeLine('开演前 120 分钟开放入场（四面台）'),
          _noticeLine('入场须安检，禁带专业摄影设备、易燃易爆及液态物品'),
          _noticeLine('1.2 米以下儿童谢绝入场'),
          _noticeLine('担保出票 · 验票保真 · 现场无法入场按 ¥500/票赔付（上限 ¥2,000）'),
        ]),
      ];

  // ── 酒店 tab：只做「选酒店 + 概览」，详细房型/设施/位置进酒店详情页(消除重复) ──
  List<Widget> _hotelTab() => [
        _card('套餐含住宿 · 一价全含', [
          const Text('每套餐均含精选酒店「非基础房型 + 双人早餐」，看演出+住宿一站搞定，比单独订更省心划算。',
              style: TextStyle(
                  fontSize: 13, height: 1.8, color: AppColors.textSecondary)),
        ]),
        _sectionHead('可选酒店 · 点击查看详情'),
        _hotelCard('尖沙咀凯悦', '豪华海景房 + 双早', '距场馆 15 分钟', 1, 5, 0),
        _hotelCard('红磡海景酒店', '海景双床房 + 双早', '步行 10 分钟直达', 2, 4, 1),
        _hotelCard('旺角智选假日', '高级双床房 + 双早', '地铁 2 站', 3, 4, 2),
      ];

  // 演出海报（竖版官方海报感）
  Widget _posterCard() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 120,
              height: 168,
              child: Image.asset('assets/images/poster_1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.card)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('嘉年华 CARNIVAL',
                      style: AppTheme.displaySerif(size: 20)),
                  const SizedBox(height: 6),
                  const Text('世界巡回演唱会 · 香港站',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6, children: const [
                    _MiniTag('华语流行'),
                    _MiniTag('时长约 180 分钟'),
                    _MiniTag('国语'),
                  ]),
                ]),
          ),
        ]),
      );

  // 演出看点网格
  Widget _highlightGrid() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Row(children: [
          Expanded(child: _highlightCell(LucideIcons.disc3, '25 周年', '经典曲目全回顾')),
          const SizedBox(width: 10),
          Expanded(child: _highlightCell(LucideIcons.sparkles, '全新舞美', '360°环形舞台')),
          const SizedBox(width: 10),
          Expanded(child: _highlightCell(LucideIcons.users, '神秘嘉宾', '现场揭晓')),
        ]),
      );

  Widget _highlightCell(IconData icon, String title, String sub) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          Icon(icon, size: 20, color: AppColors.amber),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9.5, color: AppColors.textTertiary)),
        ]),
      );

  // 往期现场横滑
  // 真实购票评价墙(social proof:横向滚动卡,评分 4.3 显真实)
  static const _reviews = [
    ['小艺', 5, '出票很快', '下单第二天就出票了,还上传了实体票实拍,超安心。', '08/12'],
    ['Kevin', 4, '座位真实', '内场企位和描述一致,位置很好,顺丰隔天到。', '08/10'],
    ['圆圆', 5, '担保靠谱', '官方售罄这里还有票,真的稳,朋友都问我哪买的。', '08/08'],
    ['阿德', 4, '套餐省心', '票+酒店一起订省了不少事,酒店还含双早。', '08/05'],
  ];

  Widget _reviewWall() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: Row(children: [
              const Icon(LucideIcons.star, size: 15, color: AppColors.amber),
              const SizedBox(width: 6),
              const Text('4.3',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber)),
              const SizedBox(width: 6),
              Text('· 基于 2,164 条真实购票评价',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            ]),
          ),
          SizedBox(
            height: 138,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _reviewCard(_reviews[i]),
            ),
          ),
        ],
      );

  Widget _reviewCard(List<Object> r) {
    final stars = r[1] as int;
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.amber.withValues(alpha: 0.2),
                child: Text((r[0] as String).characters.first,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber)),
              ),
              const SizedBox(width: 8),
              Text(r[0] as String,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              Row(
                  children: List.generate(
                      5,
                      (s) => Icon(LucideIcons.star,
                          size: 10,
                          color: s < stars
                              ? AppColors.amber
                              : AppColors.textFaint))),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(r[2] as String,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(r[3] as String,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: AppColors.textSecondary)),
            ),
            Text(r[4] as String,
                style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
          ]),
    );
  }

  // 近期成交流水(实时感 social proof)
  static const _deals = [
    ['王**', '内场企位 × 2', '刚刚'],
    ['陈**', 'A区看台 × 2', '2 分钟前'],
    ['林**', '套餐 · B区 + 凯悦', '5 分钟前'],
  ];

  Widget _recentDeals() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(
              children: _deals.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                      text: TextSpan(
                          text: '${d[0]} ',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary),
                          children: [
                        TextSpan(
                            text: '刚买了 ${d[1]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.textTertiary)),
                      ])),
                ),
                Text(d[2] as String,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textFaint)),
              ]),
            );
          }).toList()),
        ),
      );

  Widget _pastGallery() => SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 150,
              child: Image.asset('assets/images/concert_${i + 1}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.card)),
            ),
          ),
        ),
      );

  // 基本信息条（时间/场馆/票种）
  // 紧迫感条(真实库存/热度,服务成交)
  Widget _urgencyStrip() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: const Color(0x22FF785A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x44FF785A))),
          child: Row(children: const [
            Icon(LucideIcons.flame, size: 15, color: AppColors.deal),
            SizedBox(width: 8),
            Expanded(
              child: Text('本场仅剩 32 张 · 近 24h 已售 218 张',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE0A58A))),
            ),
            Text('手慢无',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deal)),
          ]),
        ),
      );

  Widget _infoStrip() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            _infoLine(LucideIcons.calendar, '演出时间', widget.dateText),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.line, height: 1),
            ),
            _infoLine(LucideIcons.mapPin, '演出场馆', widget.venue),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.line, height: 1),
            ),
            _infoLine(LucideIcons.ticket, '票种', '纸质票 · 不实名 · 支持转赠'),
          ]),
        ),
      );

  Widget _infoLine(IconData icon, String label, String value) => Row(children: [
        Icon(icon, size: 15, color: AppColors.amber),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600)),
      ]);

  // ── 复用小组件 ──
  Widget _card(String? title, List<Widget> children) => Padding(
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
                if (title != null) ...[
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                ],
                ...children,
              ]),
        ),
      );

  Widget _sectionHead(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        child: Text(t,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );

  Widget _lineupRow(String name, String role, int seed) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
        child: Row(children: [
          PosterBox(
              width: 44,
              height: 44,
              seed: seed,
              radius: BorderRadius.circular(22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(role,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ]),
          ),
        ]),
      );

  Widget _venueCard() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                child: Stack(fit: StackFit.expand, children: [
                  PosterBox(seed: 4),
                  DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.scrim())),
                  const Positioned(
                    left: 14,
                    bottom: 10,
                    child: Text('启德体育园主场馆',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: const [
                Icon(LucideIcons.mapPin, size: 14, color: AppColors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text('香港九龙启德承丰道 · 可容纳 5 万人',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
                Text('查看地图 ›',
                    style: TextStyle(fontSize: 11, color: AppColors.amber)),
              ]),
            ),
          ]),
        ),
      );

  Widget _noticeLine(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.check, size: 13, color: AppColors.amber),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
          ),
        ]),
      );

  Widget _hotelCard(String name, String room, String dist, int imgIdx,
          int star, int hotelIdx) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: PressableScale(
          onTap: () =>
              AppRoute.to(context, HotelDetailScreen(hotel: kHotels[hotelIdx])),
          child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 130,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/hotel_$imgIdx.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.bgElevate)),
                  DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.scrim())),
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('非基础房型 + 双早',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amberInk)),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    child: Row(children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(width: 6),
                      Row(
                          children: List.generate(
                              star,
                              (_) => const Icon(LucideIcons.star,
                                  size: 10, color: AppColors.amber))),
                    ]),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
                ),
                Row(children: [
                  const Icon(LucideIcons.footprints,
                      size: 12, color: AppColors.textFaint),
                  const SizedBox(width: 4),
                  Text(dist,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textFaint)),
                ]),
              ]),
            ),
          ]),
        ),
        ),
      );

  // ── sticky 购买栏（预估最低价 + 票根CTA）──
  Widget _stickyBuy() => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
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
                  const Text('套餐预估最低',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textTertiary)),
                  RichText(
                      text: TextSpan(
                          text: '¥4,180',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amber),
                          children: const [
                        TextSpan(
                            text: ' 起',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary))
                      ])),
                ]),
            const Spacer(),
            _TicketCta(
                onTap: () =>
                    AppRoute.to(context, const PackageBuilderScreen())),
          ]),
        ),
      );
}

/// 小标签（房型/曲风/时长等）
class _MiniTag extends StatelessWidget {
  final String text;
  const _MiniTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.bgElevate,
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    );
  }
}

/// 票根风 CTA（吸收 Mo Ticket 橙色 BUY NOW 齿边票根）
class _TicketCta extends StatelessWidget {
  final VoidCallback onTap;
  const _TicketCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.amberGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x59C9962F), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.ticket, size: 16, color: AppColors.amberInk),
          SizedBox(width: 6),
          Text('立即购买',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.amberInk)),
        ]),
      ),
    );
  }
}
