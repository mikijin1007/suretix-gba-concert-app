import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_intro_screen.dart';

/// 全部巡演 —— 3 列海报网格（参考大麦「全部巡演」）。
/// 海报左下角「热卖中/暂时缺票」+ 右下角城市，下方两行标题。
class AllToursScreen extends StatefulWidget {
  final String title;
  final List<TourItem> items;
  const AllToursScreen({
    super.key,
    this.title = '全部巡演',
    required this.items,
  });

  @override
  State<AllToursScreen> createState() => _AllToursScreenState();
}

class _AllToursScreenState extends State<AllToursScreen> {
  int _sort = 0; // 0=推荐优先 1=开演最近 2=在售优先

  List<TourItem> get _list {
    final l = List<TourItem>.from(widget.items);
    if (_sort == 1) {
      l.sort((a, b) => a.dateText.compareTo(b.dateText));
    } else if (_sort == 2) {
      l.sort((a, b) {
        if (a.soldOut == b.soldOut) return 0;
        return a.soldOut ? 1 : -1; // 在售的排前面
      });
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(children: [
        _filterRow(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 10,
              childAspectRatio: 0.56, // 海报 3:4 + 两行标题
            ),
            itemCount: _list.length,
            itemBuilder: (_, i) => _cell(context, _list[i]),
          ),
        ),
      ]),
    );
  }

  // 筛选栏（与折扣尾票页一致）
  Widget _filterRow() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Row(children: [
          _sortBtn('推荐优先', 0, highlight: true),
          const SizedBox(width: 22),
          _sortBtn('开演最近', 1),
          const SizedBox(width: 22),
          _sortBtn('在售优先', 2),
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

  Widget _cell(BuildContext context, TourItem t) => PressableScale(
        onTap: () => AppRoute.to(
            context,
            EventIntroScreen(
              artist: t.title,
              subtitle: '${t.city} · ${t.venue}',
              venueLine: '${t.city} · ${t.venue} · ${t.dateText}',
              dateText: t.dateText,
              venue: t.venue,
              seed: t.seed,
            )),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 海报 + 底部状态条
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(fit: StackFit.expand, children: [
                    PosterBox(seed: t.seed),
                    // 左上角状态角标（带背景）
                    Positioned(
                      left: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: t.soldOut
                              ? const Color(0xCC2A2A2E)
                              : AppColors.amber,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              t.soldOut
                                  ? LucideIcons.clock
                                  : LucideIcons.flame,
                              size: 8.5,
                              color: Colors.white),
                          const SizedBox(width: 2),
                          Text(t.soldOut ? '暂时缺票' : '热卖中',
                              style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ]),
                      ),
                    ),
                    // 右下角城市（黑色背景胶囊）
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(t.city,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 7),
              Text(t.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700)),
            ]),
      );
}

/// 巡演条目
class TourItem {
  final String title;
  final String city;
  final String venue;
  final String dateText;
  final int seed;
  final bool soldOut;
  const TourItem({
    required this.title,
    required this.city,
    required this.venue,
    required this.dateText,
    required this.seed,
    this.soldOut = false,
  });
}

/// 热门演出 · 全部
const kHotTours = <TourItem>[
  TourItem(
      title: '周杰伦 嘉年华世界巡回演唱会',
      city: '中国香港',
      venue: '启德体育园主场馆',
      dateText: '2026/08/29–31 · 20:00',
      seed: 0),
  TourItem(
      title: 'MIRROR 演唱会 2026',
      city: '中国香港',
      venue: '亚洲国际博览馆',
      dateText: '2026/09/12–13 · 20:00',
      seed: 3),
  TourItem(
      title: '邓紫棋《I AM GLORIA》世界巡演',
      city: '中国香港',
      venue: '香港体育馆',
      dateText: '2026/08/30 · 20:00',
      seed: 5),
  TourItem(
      title: '陈奕迅 FEAR不惧 巡回演唱会',
      city: '中国香港',
      venue: '红磡体育馆',
      dateText: '2026/10/05–06 · 20:00',
      seed: 1),
  TourItem(
      title: '五月天 好好好想见到你',
      city: '中国香港',
      venue: '启德体育园主场馆',
      dateText: '2026/09/21 · 19:30',
      seed: 4),
  TourItem(
      title: '林俊杰 JJ20 世界巡回演唱会',
      city: '中国香港',
      venue: '亚洲国际博览馆',
      dateText: '2026/09/14 · 20:00',
      seed: 2),
  TourItem(
      title: '薛之谦「万兽之王」巡回演唱会',
      city: '中国澳门',
      venue: '澳门伦敦人综合体育馆',
      dateText: '2026/10/01–11 · 20:00',
      seed: 6,
      soldOut: true),
  TourItem(
      title: '李榮浩「黑馬」巡回演唱会',
      city: '中国香港',
      venue: '香港体育馆',
      dateText: '2026/09/25–26 · 20:00',
      seed: 3),
  TourItem(
      title: 'BLACKPINK 世界巡回演唱会',
      city: '中国香港',
      venue: '启德体育园主场馆',
      dateText: '2026/11/02 · 19:30',
      seed: 7),
  TourItem(
      title: '林忆莲《呼吸》巡回演唱会',
      city: '中国香港',
      venue: '香港会展中心',
      dateText: '2026/10/12 · 20:00',
      seed: 7),
  TourItem(
      title: '张学友 60+ 巡回演唱会',
      city: '广州',
      venue: '广州天河体育中心',
      dateText: '2026/11/15–16 · 19:30',
      seed: 1,
      soldOut: true),
  TourItem(
      title: '孙燕姿《就在日落以后》巡演',
      city: '深圳',
      venue: '深圳湾体育中心',
      dateText: '2026/10/18 · 20:00',
      seed: 5),
];

/// 近期演出 · 全部
const kUpcomingTours = <TourItem>[
  TourItem(
      title: '林俊杰 JJ20 世界巡回演唱会',
      city: '中国香港',
      venue: '亚洲国际博览馆',
      dateText: '2026/09/15 · 20:00',
      seed: 2),
  TourItem(
      title: '五月天 好好好想见到你',
      city: '中国香港',
      venue: '启德体育园主场馆',
      dateText: '2026/09/15 · 19:30',
      seed: 4),
  TourItem(
      title: '薛之谦 天外来物巡回演唱会',
      city: '中国香港',
      venue: '香港体育馆',
      dateText: '2026/09/15 · 20:00',
      seed: 6),
  TourItem(
      title: '音乐剧《风声》',
      city: '中国香港',
      venue: '西九文化区戏曲中心',
      dateText: '2026/09/15–10/07',
      seed: 3),
  TourItem(
      title: '邓紫棋 G.E.M. 世界巡演',
      city: '中国香港',
      venue: '香港体育馆',
      dateText: '2026/09/16 · 20:00',
      seed: 5),
  TourItem(
      title: '林忆莲《呼吸》巡回演唱会',
      city: '中国香港',
      venue: '香港会展中心',
      dateText: '2026/09/16 · 20:00',
      seed: 7),
  TourItem(
      title: 'MIRROR 演唱会 2026',
      city: '中国香港',
      venue: '亚洲国际博览馆',
      dateText: '2026/09/18 · 20:00',
      seed: 3),
  TourItem(
      title: '陈奕迅 FEAR不惧 巡回演唱会',
      city: '中国香港',
      venue: '红磡体育馆',
      dateText: '2026/09/18 · 20:00',
      seed: 1),
  TourItem(
      title: '港超联赛 · 南区 vs 杰志',
      city: '中国香港',
      venue: '香港大球场',
      dateText: '2026/09/18 · 15:30',
      seed: 7),
  TourItem(
      title: '舞剧《咏春》',
      city: '深圳',
      venue: '深圳保利剧院',
      dateText: '2026/09/18–21',
      seed: 2),
  TourItem(
      title: '周杰伦 嘉年华世界巡回演唱会',
      city: '中国香港',
      venue: '启德体育园主场馆',
      dateText: '2026/09/19–20 · 20:00',
      seed: 0),
  TourItem(
      title: '歌者归来超级歌会',
      city: '中国香港',
      venue: '亚洲国际博览馆',
      dateText: '2026/09/19 · 19:00',
      seed: 1),
  TourItem(
      title: '广州国际音乐节 2026',
      city: '广州',
      venue: '广州天河体育中心',
      dateText: '2026/09/19 · 全天',
      seed: 4),
  TourItem(
      title: '薛之谦「万兽之王」巡回演唱会',
      city: '中国澳门',
      venue: '澳门伦敦人综合体育馆',
      dateText: '2026/09/19 · 20:00',
      seed: 6),
  TourItem(
      title: '李榮浩「黑馬」巡回演唱会',
      city: '中国香港',
      venue: '香港体育馆',
      dateText: '2026/09/20 · 20:00',
      seed: 3,
      soldOut: true),
];
