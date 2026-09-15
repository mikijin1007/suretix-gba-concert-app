import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/hero_carousel.dart';
import 'event_intro_screen.dart';
import 'discount_list_screen.dart';
import 'all_tours_screen.dart';
import 'order_center_screen.dart';
import 'main_shell.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';

/// 首页 —— 流媒体版式（参考 Figma）：品牌头 + 分类胶囊 Tab + 英雄大卡
/// + 热门演出横滑 + 近期演出横滑 + 信任窄带。主题强调色保持粉色。
/// 品牌：穩飛 / SureTix，主打担保出票。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _calSel = 0; // 选中的日历日期索引

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        children: [
          // 首屏主视觉：立即在场，只淡入不滑动（不参与 stagger）
          _topBar().animate().fadeIn(duration: 300.ms),
          _noticeBar().animate().fadeIn(duration: 320.ms, delay: 60.ms),
          Builder(
            builder: (ctx) => HeroCarousel(
              slides: _heroSlides,
              onTapSlide: (i) {
                final s = _heroSlides[i];
                AppRoute.to(
                    ctx,
                    EventIntroScreen(
                      artist: s.title,
                      subtitle: s.subtitle,
                      venueLine: s.meta,
                      // meta 格式："场馆 · 日期 · 场次" → 时间取日期段,场馆取首段
                      dateText: s.meta.split('·').length > 1
                          ? s.meta.split('·')[1].trim()
                          : s.meta,
                      venue: s.meta.split('·').first.trim(),
                      seed: s.seed,
                    ));
              },
            ),
          ).animate().fadeIn(duration: 420.ms, delay: 100.ms),
          // 以下内容区：stagger 淡入+上滑
          ...[
            Transform.translate(
              offset: const Offset(0, -10),
              child: _sectionLabel('热门演出', 'HOT SHOWS',
                  onTap: () => AppRoute.to(
                      context,
                      const AllToursScreen(
                          title: '全部巡演', items: kHotTours))),
            ),
            _hotRow(context),
            // 折扣尾票：标题 + 标签行 + 竖排折扣卡（点全部进列表页）
            _discountHeader(context),
            _discountList(context),
            _sectionLabel('近期演出', 'UPCOMING',
                onTap: () => AppRoute.to(
                    context,
                    const AllToursScreen(
                        title: '近期演出', items: kUpcomingTours))),
            // 标题下方：一行可横滑日历（按日期看有哪些演出）
            _calendarRow(context),
            _upcomingRow(context),
          ]
              .animate(interval: 55.ms)
              .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
              .slideY(
                  begin: 0.06,
                  end: 0,
                  duration: 340.ms,
                  curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // ── 品牌头 TopBar：SURE TIX + slogan + 搜索/铃铛/头像 ──
  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: 'SURE ',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: 1,
                            color: AppColors.textPrimary)),
                    TextSpan(
                        text: 'TIX',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: 1,
                            color: AppColors.amber)),
                  ]),
                ),
                SizedBox(height: 3),
                Text("let's stream to the max",
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
            const Spacer(),
            // 搜索
            Builder(
              builder: (ctx) => PressableScale(
                ensureHitArea: true,
                onTap: () => AppRoute.to(ctx, const SearchScreen()),
                child: const Icon(LucideIcons.search,
                    size: 20, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            // 铃铛（右上角粉色小红点）
            Builder(
              builder: (ctx) => PressableScale(
                ensureHitArea: true,
                onTap: () => AppRoute.to(ctx, const NotificationsScreen()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(LucideIcons.bell,
                        size: 20, color: AppColors.textPrimary),
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bg, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ── 顶部通知条（图2 担保文案）：黑底横条 + 双心图标 + 文案 + GO，点击弹担保详情 ──
  Widget _noticeBar() => Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 2, 22, 16),
          child: PressableScale(
            onTap: () => _showGuaranteeSheet(ctx),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.only(left: 74, right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33E5477B)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1FE5477B),
                          blurRadius: 18,
                          offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: '抢不到？',
                                    style: TextStyle(
                                        fontSize: 15.5,
                                        height: 1.15,
                                        color: AppColors.amber,
                                        fontWeight: FontWeight.w900)),
                                TextSpan(
                                    text: '我们担保出票',
                                    style: TextStyle(
                                        fontSize: 15.5,
                                        height: 1.15,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800)),
                              ]),
                            ),
                            SizedBox(height: 3),
                            Text('验票保真 · 现场兜底 · 出不了全额退+赔付',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textTertiary)),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    // 右侧圆形箭头按钮
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x59E5477B),
                              blurRadius: 10,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.arrowRight,
                            size: 18, color: AppColors.amberInk),
                      ),
                    ),
                  ]),
                ),
                // 左侧多米双心图标（无背景，浮在横条上）
                Positioned(
                  left: 6,
                  top: -4,
                  child: SizedBox(
                    width: 62,
                    height: 72,
                    child: Image.asset('assets/images/guard_hearts.png',
                        fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ── 本周王牌 轮播数据 ──
  static const _heroSlides = [
    HeroSlide(
        tagline: '官方售罄 · 我们仍有票',
        title: '周杰伦',
        subtitle: '嘉年华巡演',
        meta: '启德体育园 · 8月29–31日 · 3场',
        price: '¥3,280',
        seed: 0),
    HeroSlide(
        tagline: '万人合唱现场',
        title: '五月天',
        subtitle: '好好好想见到你',
        meta: '启德主场馆 · 9月21日',
        price: '¥3,280',
        seed: 4),
    HeroSlide(
        tagline: '限时预售 · 早鸟价',
        title: '邓紫棋',
        subtitle: 'G.E.M. 世界巡演',
        meta: '香港体育馆 · 8月30日',
        price: '¥2,180',
        seed: 3),
  ];

  // ── section 标签：中文粗体 + 英文大写点缀 + 右侧全部→ ──
  Widget _sectionLabel(String zh, String en, {VoidCallback? onTap}) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(zh,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, height: 1.0)),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(en,
                style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFaint)),
          ),
          const Spacer(),
          // 下移到与标题基线齐平（标题 20px，此处 11px，默认会偏上）
          Transform.translate(
            offset: const Offset(0, 4),
            child: PressableScale(
              onTap: onTap,
              ensureHitArea: true,
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Text('全部',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
                SizedBox(width: 3),
                Icon(LucideIcons.arrowRight,
                    size: 15, color: AppColors.textTertiary),
              ]),
            ),
          ),
        ]),
      );

  // ── 热门演出：横滑卡列表 ──
  // [名, 评分, 场次或类型, 价格, 图seed, 我方余票left, 演出日期, 演出场馆]
  Widget _hotRow(BuildContext context) {
    final rows = [
      ['周杰伦 嘉年华巡演', '11.2万', '演唱会 · 3场', '¥3,280', 0, 12,
        '2026/08/29–31 · 20:00', '香港 · 启德体育园主场馆'],
      ['MIRROR 演唱会', '8.6万', '演唱会 · 亚博馆', '¥2,180', 3, 18,
        '2026/09/12–13 · 20:00', '香港 · 亚洲国际博览馆'],
      ['邓紫棋 G.E.M.', '9.4万', '世界巡演 · 港馆', '¥2,180', 5, 4,
        '2026/08/30 · 20:00', '香港 · 香港体育馆'],
      ['陈奕迅 FEAR不惧', '10.1万', '演唱会 · 红磡', '¥2,180', 1, 6,
        '2026/10/05–06 · 20:00', '香港 · 红磡体育馆'],
    ];
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 6),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _showCard(context, rows[i], hot: true),
      ),
    );
  }

  // ── 近期演出：按日历选中日期切换 ──
  // 每个日期对应的演出列表 [名, 想看人数, 日期场馆, 价格, 图seed, 余票]
  static const _upcomingByDay = <List<List<Object>>>[
    // 9/15 今天 · 6场
    [
      ['林俊杰 JJ20 世界巡演', '7.8万', '9月15日 · 亚博馆', '¥2,480', 2, 25],
      ['五月天 好好好想见到你', '13.5万', '9月15日 · 启德', '¥3,280', 4, 9],
      ['薛之谦 天外来物', '6.2万', '9月15日 · 港馆', '¥1,880', 6, 3],
      ['音乐剧《风声》', '2.1万', '9月15日 · 戏曲中心', '¥289', 3, 40],
    ],
    // 9/16 · 3场
    [
      ['邓紫棋 G.E.M. 世界巡演', '9.4万', '9月16日 · 港馆', '¥2,180', 5, 12],
      ['林忆莲 呼吸', '4.3万', '9月16日 · 会展', '¥1,380', 7, 20],
      ['音乐剧《风声》', '2.1万', '9月16日 · 戏曲中心', '¥289', 3, 33],
    ],
    // 9/17 · 无演出
    [],
    // 9/18 · 5场
    [
      ['MIRROR 演唱会', '8.6万', '9月18日 · 亚博馆', '¥2,180', 3, 18],
      ['陈奕迅 FEAR不惧', '10.1万', '9月18日 · 红磡', '¥2,180', 1, 6],
      ['港超联赛 · 南区 vs 杰志', '1.2万', '9月18日 · 大球场', '¥128', 7, 60],
      ['舞剧《咏春》', '3.4万', '9月18日 · 保利剧院', '¥220', 2, 28],
    ],
    // 9/19 · 8场
    [
      ['周杰伦 嘉年华巡演', '11.2万', '9月19日 · 启德', '¥3,280', 0, 12],
      ['歌者归来超级歌会', '5.6万', '9月19日 · 亚博馆', '¥460', 1, 22],
      ['广州国际音乐节', '4.8万', '9月19日 · 天河体育中心', '¥380', 4, 45],
      ['薛之谦 万兽之王', '6.9万', '9月19日 · 伦敦人', '¥783', 6, 15],
    ],
    // 9/20 · 7场
    [
      ['周杰伦 嘉年华巡演', '11.2万', '9月20日 · 启德', '¥3,280', 0, 8],
      ['李榮浩 黑馬巡演', '5.1万', '9月20日 · 港馆', '¥700', 3, 30],
      ['港超联赛 · 南区 vs 杰志', '1.2万', '9月20日 · 大球场', '¥128', 7, 52],
    ],
    // 9/21 · 2场
    [
      ['五月天 好好好想见到你', '13.5万', '9月21日 · 启德', '¥3,280', 4, 9],
      ['舞剧《咏春》', '3.4万', '9月21日 · 保利剧院', '¥220', 2, 19],
    ],
    // 9/22 · 4场
    [
      ['邓紫棋 G.E.M. 世界巡演', '9.4万', '9月22日 · 港馆', '¥2,180', 5, 7],
      ['音乐剧《风声》', '2.1万', '9月22日 · 戏曲中心', '¥289', 3, 26],
      ['林忆莲 呼吸', '4.3万', '9月22日 · 会展', '¥1,380', 7, 16],
    ],
    // 9/23 · 1场
    [
      ['薛之谦 万兽之王', '6.9万', '9月23日 · 伦敦人', '¥783', 6, 11],
    ],
    // 9/24 · 3场
    [
      ['陈奕迅 FEAR不惧', '10.1万', '9月24日 · 红磡', '¥2,180', 1, 5],
      ['广州国际音乐节', '4.8万', '9月24日 · 天河体育中心', '¥380', 4, 38],
      ['李榮浩 黑馬巡演', '5.1万', '9月24日 · 港馆', '¥700', 3, 24],
    ],
  ];

  Widget _upcomingRow(BuildContext context) {
    final rows = _upcomingByDay[_calSel];
    // 当日无演出：给出空态而不是空白
    if (rows.isEmpty) {
      return Container(
        height: 132,
        margin: const EdgeInsets.fromLTRB(22, 2, 22, 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.calendarOff, size: 26, color: AppColors.textFaint),
          SizedBox(height: 10),
          Text('这天暂无演出',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          SizedBox(height: 5),
          Text('看看其他日期的精彩演出',
              style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
        ]),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 6),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _showCard(context, rows[i], hot: false),
      ),
    );
  }

  // ── 折扣尾票：标题（含在打折场次数）+ 右侧箭头进全部列表 ──
  Widget _discountHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
        child: PressableScale(
          onTap: () => AppRoute.to(context, const DiscountListScreen()),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text('折扣尾票',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, height: 1.0)),
            const SizedBox(width: 10),
            Flexible(
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Text('1746',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.amber)),
                SizedBox(width: 2),
                Text('场演出正在打折~',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.amber)),
              ]),
            ),
            const Spacer(),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textTertiary),
          ]),
        ),
      );

  // ── 折扣尾票：首页只展示前 3 条，样式与列表页一致 ──
  Widget _discountList(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
        child: Column(children: [
          for (int i = 0; i < 3 && i < kDiscountShows.length; i++) ...[
            if (i > 0)
              const Divider(height: 24, thickness: 1, color: AppColors.line),
            _discountCard(context, kDiscountShows[i]),
          ],
        ]),
      );

  // ── 折扣卡：左海报 + 右信息（城市标 + 标题 + 日期场馆 + 折扣/起价）──
  Widget _discountCard(BuildContext context, DiscountShow s) => PressableScale(
        onTap: () => AppRoute.to(
            context,
            EventIntroScreen(
              artist: s.title,
              subtitle: '${s.city} · ${s.venue}',
              venueLine: '${s.city} · ${s.venue} · ${s.dateRange}',
              dateText: s.dateRange,
              venue: s.venue,
              seed: s.seed,
            )),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
                width: 110, height: 132, child: PosterBox(seed: s.seed)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 城市标单独一行，放在标题上方
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: AppColors.textFaint, width: 0.8)),
                    child: Text(s.city,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 8),
                  Text(s.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(s.dateRange,
                      style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(s.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(3)),
                      child: Text('${_fmtDiscount(s.discount)}折起',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Text('¥ ${s.fromPrice}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.amber)),
                    const SizedBox(width: 2),
                    const Text('起',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amber)),
                  ]),
                ]),
          ),
        ]),
      );

  static String _fmtDiscount(double d) =>
      d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(1);

  // ── 近期演出下方：横滑日历（日期 + 当日场次数，点击进演出列表）──
  // [月, 日, 周, 当日场次数]（场次数与 _upcomingByDay 条数保持一致）
  static const _calDays = [
    [9, 15, '今天', 4],
    [9, 16, '周三', 3],
    [9, 17, '周四', 0],
    [9, 18, '周五', 4],
    [9, 19, '周六', 4],
    [9, 20, '周日', 3],
    [9, 21, '周一', 2],
    [9, 22, '周二', 3],
    [9, 23, '周三', 1],
    [9, 24, '周四', 3],
  ];

  Widget _calendarRow(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        child: SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: _calDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final d = _calDays[i];
              final count = d[3] as int;
              final sel = i == _calSel; // 选中态（默认今天）
              final hasShow = count > 0;
              return PressableScale(
                onTap: () => setState(() => _calSel = i),
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                      gradient: sel ? AppColors.amberGradient : null,
                      color: sel ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: sel
                              ? Colors.transparent
                              : AppColors.cardBorder)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d[2] as String,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? AppColors.amberInk
                                    : AppColors.textTertiary)),
                        const SizedBox(height: 3),
                        Text('${d[1]}',
                            style: TextStyle(
                                fontSize: 19,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                color: sel
                                    ? AppColors.amberInk
                                    : AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        // 有演出显示场次数，没有则显示占位点
                        hasShow
                            ? Text('$count场',
                                style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: sel
                                        ? AppColors.amberInk
                                        : AppColors.amber))
                            : Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                    color: AppColors.textFaint,
                                    shape: BoxShape.circle),
                              ),
                      ]),
                ),
              );
            },
          ),
        ),
      );

  // ── 统一横滑卡：缩略图 + 播放钮 + 角标 / 标题 + 评分 + 价格 ──
  Widget _showCard(BuildContext context, List r, {required bool hot}) {
    final left = r[5] as int;
    final title = r[0] as String;
    final sp = title.indexOf(' ');
    final artist = sp > 0 ? title.substring(0, sp) : title;
    final subtitle = sp > 0 ? title.substring(sp + 1) : '';
    return PressableScale(
      onTap: () => AppRoute.to(
          context,
          EventIntroScreen(
            artist: artist,
            subtitle: subtitle,
            venueLine: '${r[7]} · ${(r[6] as String).split('·').first.trim()}',
            dateText: '${r[6]}',
            venue: '${r[7]}',
            seed: r[4] as int,
          )),
      child: SizedBox(
        width: 150,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 108,
              width: 150,
              child: Stack(fit: StackFit.expand, children: [
                PosterBox(seed: r[4] as int),
                DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.scrim())),
                // 左上角标：紧迫(仅剩N张) / 热门 / 近期
                Positioned(
                  top: 10,
                  left: 10,
                  child: left <= 6
                      ? _UrgencyPill(left)
                      : _MiniTag(hot ? '热门' : '近期'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text(r[0] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(LucideIcons.flame, size: 12, color: AppColors.amber),
            const SizedBox(width: 3),
            Text('${r[1]}人想看',
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 6),
          RichText(
              text: TextSpan(
                  text: r[3] as String,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber),
                  children: const [
                TextSpan(
                    text: ' 起',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary))
              ])),
        ]),
      ),
    );
  }

  // ── 信任窄带（粉色渐变边框）──
  // ── 信任 banner（参考"运动战报"风：横条 + 左侧探出立体角色 + 文案 + 右侧圆形 GO）──
  Widget _trustStrip() => Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
          child: PressableScale(
            onTap: () => _showGuaranteeSheet(ctx),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 主体横条（黑底 + 细粉边）
                Container(
                  height: 72,
                  padding: const EdgeInsets.only(left: 80, right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33E5477B)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1FE5477B),
                          blurRadius: 18,
                          offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: '抢不到？',
                                    style: TextStyle(
                                        fontSize: 16.5,
                                        height: 1.15,
                                        color: AppColors.amber,
                                        fontWeight: FontWeight.w900)),
                                TextSpan(
                                    text: '我们担保出票',
                                    style: TextStyle(
                                        fontSize: 16.5,
                                        height: 1.15,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800)),
                              ]),
                            ),
                            SizedBox(height: 4),
                            Text('验票保真 · 现场兜底 · 出不了全额退+赔付',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textTertiary)),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    // 右侧圆形 GO 按钮（粉底 + 深字）
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x59E5477B),
                              blurRadius: 10,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Center(
                        child: Text('GO',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: AppColors.amberInk)),
                      ),
                    ),
                  ]),
                ),
                // 左侧探出的多米双心图标（无背景，直接浮在横条上，顶部溢出）
                Positioned(
                  left: 8,
                  top: -6,
                  child: SizedBox(
                    width: 66,
                    height: 78,
                    child: Image.asset('assets/images/guard_hearts.png',
                        fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ── 担保详情：可上拉的底部弹窗（半透明遮罩背景 + 可拖拽把手）──
  void _showGuaranteeSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB3000000),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (c, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgElevate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
                top: BorderSide(color: Color(0x40E5477B)),
                left: BorderSide(color: Color(0x1AE5477B)),
                right: BorderSide(color: Color(0x1AE5477B))),
          ),
          child: Column(
            children: [
              // 拖拽把手
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x40FFFFFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(LucideIcons.shieldCheck,
                            size: 24, color: AppColors.amberInk),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text('担保出票 · 穩飛承诺',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _guaranteeItem(LucideIcons.ticketCheck, '担保出票',
                        '别处抢不到？我们承诺担保出票。下单后由平台锁票，确保你拿到真实有效门票。'),
                    _guaranteeItem(LucideIcons.badgeCheck, '验票保真',
                        '每张票经过多重核验，来源可溯，杜绝假票、废票，入场无忧。'),
                    _guaranteeItem(LucideIcons.umbrella, '现场兜底',
                        '若临场出现任何出票异常，平台现场协调补位或就近同档座位兜底。'),
                    _guaranteeItem(LucideIcons.wallet, '全额退 + 赔付',
                        '万一最终无法出票，全额退款，并额外按票面比例赔付，绝不让你白等。'),
                    const SizedBox(height: 24),
                    PressableScale(
                      onTap: () {
                        Navigator.of(c).pop();
                        AppRoute.to(ctx, const OrderCenterScreen());
                      },
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x59E5477B),
                                blurRadius: 16,
                                offset: Offset(0, 6)),
                          ],
                        ),
                        child: const Text('查看我的订单',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amberInk)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guaranteeItem(IconData icon, String title, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0x24E5477B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x40E5477B)),
            ),
            child: Icon(icon, size: 17, color: AppColors.amber),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppColors.textTertiary)),
                ]),
          ),
        ]),
      );
}

/// 小角标（热门/近期）
class _MiniTag extends StatelessWidget {
  final String text;
  const _MiniTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// 热度标（仅低库存时叠加）：基于真实余票「仅剩 N 张」，制造紧迫。
class _UrgencyPill extends StatelessWidget {
  final int left;
  final bool compact;
  const _UrgencyPill(this.left, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x66FF785A))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.flame, size: compact ? 12 : 13, color: AppColors.deal),
        const SizedBox(width: 4),
        Text('仅剩 $left 张',
            style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w700,
                color: AppColors.deal)),
      ]),
    );
  }
}
