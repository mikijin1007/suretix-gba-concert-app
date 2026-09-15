import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_intro_screen.dart';

/// 折扣尾票 —— 全部打折演出列表。
/// 顶部分类 Tab + 排序/筛选 + 热门标签 + 竖排折扣卡（折扣角标 + 起价）。
class DiscountListScreen extends StatefulWidget {
  const DiscountListScreen({super.key});

  @override
  State<DiscountListScreen> createState() => _DiscountListScreenState();
}

/// 一条折扣演出
class DiscountShow {
  final String city;
  final String title;
  final String dateRange;
  final String venue;
  final List<String> tags;
  final double discount; // 折扣，如 7.6 表示 7.6 折
  final int fromPrice;
  final int seed;
  final String category;
  const DiscountShow({
    required this.city,
    required this.title,
    required this.dateRange,
    required this.venue,
    required this.tags,
    required this.discount,
    required this.fromPrice,
    required this.seed,
    required this.category,
  });
}

/// 全站折扣票源（首页模块与本页共用）
const kDiscountShows = <DiscountShow>[
  DiscountShow(
      city: '香港',
      title: '李榮浩「黑馬」巡回演唱会–香港站',
      dateRange: '2026.09.25–2026.09.26',
      venue: '香港体育馆',
      tags: ['演唱会', '李榮浩'],
      discount: 9.6,
      fromPrice: 700,
      seed: 3,
      category: '演唱会'),
  DiscountShow(
      city: '香港',
      title: '音乐剧《风声》',
      dateRange: '2026.09.15–2026.10.07',
      venue: '香港西九文化区戏曲中心',
      tags: ['音乐剧'],
      discount: 7.6,
      fromPrice: 289,
      seed: 6,
      category: '话剧歌剧'),
  DiscountShow(
      city: '澳门',
      title: '薛之谦"万兽之王"巡回演唱会–澳门站',
      dateRange: '2026.10.01–2026.10.11',
      venue: '澳门伦敦人综合体育馆',
      tags: ['演唱会', '薛之谦'],
      discount: 9.3,
      fromPrice: 783,
      seed: 5,
      category: '演唱会'),
  DiscountShow(
      city: '香港',
      title: '歌者归来超级歌会–香港站（中秋特别场）',
      dateRange: '2026.09.28–2026.09.29',
      venue: '亚洲国际博览馆',
      tags: ['演唱会', '拼盘'],
      discount: 8.5,
      fromPrice: 460,
      seed: 1,
      category: '演唱会'),
  DiscountShow(
      city: '广州',
      title: '广州国际音乐节 2026',
      dateRange: '2026.10.03–2026.10.05',
      venue: '广州天河体育中心',
      tags: ['音乐节'],
      discount: 6.8,
      fromPrice: 380,
      seed: 4,
      category: '音乐会'),
  DiscountShow(
      city: '香港',
      title: '港超联赛 · 南区 vs 杰志',
      dateRange: '2026.09.20',
      venue: '香港大球场',
      tags: ['体育赛事', '足球'],
      discount: 7.2,
      fromPrice: 128,
      seed: 7,
      category: '体育赛事'),
  DiscountShow(
      city: '深圳',
      title: '舞剧《咏春》深圳站',
      dateRange: '2026.10.08–2026.10.12',
      venue: '深圳保利剧院',
      tags: ['舞蹈芭蕾'],
      discount: 8.8,
      fromPrice: 220,
      seed: 2,
      category: '舞蹈芭蕾'),
  DiscountShow(
      city: '香港',
      title: '陈奕迅 FEAR不惧 加场',
      dateRange: '2026.10.05–2026.10.06',
      venue: '红磡体育馆',
      tags: ['演唱会', '陈奕迅'],
      discount: 9.5,
      fromPrice: 880,
      seed: 0,
      category: '演唱会'),
];

class _DiscountListScreenState extends State<DiscountListScreen> {
  int _sort = 0; // 0=折扣优先 1=价格低到高 2=开演最近

  List<DiscountShow> get _list {
    var l = kDiscountShows.toList();
    if (_sort == 0) {
      l.sort((a, b) => a.discount.compareTo(b.discount)); // 折扣低=更划算
    } else if (_sort == 1) {
      l.sort((a, b) => a.fromPrice.compareTo(b.fromPrice));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('折扣尾票',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(children: [
        _filterRow(),
        const SizedBox(height: 4),
        Expanded(
          child: list.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 26, thickness: 1, color: AppColors.line),
                  itemBuilder: (_, i) => _card(context, list[i]),
                ),
        ),
      ]),
    );
  }

  // 排序/筛选行
  Widget _filterRow() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Row(children: [
          _sortBtn('折扣优先', 0, highlight: true),
          const SizedBox(width: 22),
          _sortBtn('价格最低', 1),
          const SizedBox(width: 22),
          _sortBtn('开演最近', 2),
        ]),
      );

  Widget _sortBtn(String label, int idx, {bool highlight = false}) {
    final on = _sort == idx;
    return PressableScale(
      onTap: () => setState(() => _sort = idx),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                color: on
                    ? (highlight ? AppColors.amber : AppColors.textPrimary)
                    : AppColors.textTertiary)),
        const SizedBox(width: 3),
        Icon(LucideIcons.chevronDown,
            size: 13,
            color: on
                ? (highlight ? AppColors.amber : AppColors.textPrimary)
                : AppColors.textFaint),
      ]),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.ticketX, size: 40, color: AppColors.amber),
          SizedBox(height: 14),
          Text('暂无折扣票',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('新的折扣场次上线后会显示在这里',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ]),
      );

  // 折扣卡：左海报 + 右信息（城市标 + 标题 + 日期 + 场馆 + 标签 + 折扣/起价）
  Widget _card(BuildContext context, DiscountShow s) => PressableScale(
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
                width: 120, height: 152, child: PosterBox(seed: s.seed)),
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
                          fontSize: 14.5,
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
                  const SizedBox(height: 10),
                  // 标签
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      for (final t in s.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('#$t',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  // 折扣角标 + 起价
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(3)),
                      child: Text('${_fmt(s.discount)}折起',
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
}

/// 9.6 → "9.6"，8.0 → "8"
String _fmt(double d) =>
    d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(1);
