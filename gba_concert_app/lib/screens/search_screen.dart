import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_intro_screen.dart';

/// 搜索结果页 —— 自动聚焦输入 + 热门搜索 + mock 结果列表。后端接口预留。
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();
  final _focus = FocusNode();
  String _kw = '';

  static const _hot = ['周杰伦', 'MIRROR', '邓紫棋', '五月天', '陈奕迅', 'BLACKPINK'];
  // 结果 [演出名, 场馆日期, 最低价, 状态(0现票/1紧张), seed]
  static const _all = [
    ['周杰伦 嘉年华巡演', '香港 · 启德体育园 · 08/29', 2180, 1, 0],
    ['邓紫棋 G.E.M. 世界巡演', '香港体育馆 · 09/12', 1880, 0, 1],
    ['MIRROR 演唱会', '亚洲博览馆 · 09/20', 1280, 0, 2],
    ['五月天 好好巡演', '香港大球场 · 10/01', 1580, 1, 3],
    ['陈奕迅 FEAR&DREAMS', '红磡体育馆 · 10/15', 2080, 0, 4],
    ['BLACKPINK WORLD TOUR', '启德主场馆 · 11/02', 2680, 1, 5],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _q.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<List<Object>> get _results {
    if (_kw.isEmpty) return const [];
    return _all
        .where((e) => (e[0] as String).contains(_kw))
        .toList()
        .cast<List<Object>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          _searchBar(),
          Expanded(
            child: _kw.isEmpty ? _hotSection() : _resultList(),
          ),
        ]),
      ),
    );
  }

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder)),
              child: Row(children: [
                const Icon(LucideIcons.search,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _q,
                    focusNode: _focus,
                    onChanged: (v) => setState(() => _kw = v.trim()),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '搜索艺人 · 场次 · 场馆',
                        hintStyle: TextStyle(color: AppColors.textFaint)),
                  ),
                ),
                if (_kw.isNotEmpty)
                  PressableScale(
                    ensureHitArea: true,
                    onTap: () => setState(() {
                      _q.clear();
                      _kw = '';
                    }),
                    child: const Icon(LucideIcons.circleX,
                        size: 15, color: AppColors.textTertiary),
                  ),
              ]),
            ),
          ),
          PressableScale(
            ensureHitArea: true,
            onTap: () => Navigator.of(context).maybePop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('取消',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ),
          ),
        ]),
      );

  Widget _hotSection() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          const Text('热门搜索',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _hot
                .map((h) => PressableScale(
                      onTap: () => setState(() {
                        _q.text = h;
                        _kw = h;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder)),
                        child: Text(h,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ),
                    ))
                .toList(),
          ),
        ],
      );

  Widget _resultList() {
    final r = _results;
    if (r.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.searchX, size: 42, color: AppColors.textFaint),
            const SizedBox(height: 14),
            Text('没有找到「$_kw」相关演出',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('也许还没上架,或换个关键词试试。也可以从下面的热门演出找找看。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            PressableScale(
              onTap: () => setState(() {
                _q.clear();
                _kw = '';
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(24)),
                child: const Text('看看热门演出',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberInk)),
              ),
            ),
          ]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: r.length,
      itemBuilder: (_, i) => _resultCard(r[i]),
    );
  }

  Widget _resultCard(List<Object> e) {
    final status = e[3] as int;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PressableScale(
        onTap: () => AppRoute.to(context, const EventIntroScreen()),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: PosterBox(seed: e[4] as int, width: 84, height: 84),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e[0] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(e[1] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: (status == 1 ? AppColors.deal : AppColors.green)
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(status == 1 ? '仅剩少量' : '現票充足',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: status == 1 ? AppColors.deal : AppColors.green)),
                      ),
                      const Spacer(),
                      RichText(
                          text: TextSpan(
                              text: '¥${e[2]}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amber),
                              children: const [
                            TextSpan(
                                text: ' 起',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textFaint))
                          ])),
                    ]),
                  ]),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(LucideIcons.chevronRight,
                  size: 16, color: AppColors.textFaint),
            ),
          ]),
        ),
      ),
    );
  }
}
