import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_intro_screen.dart';
import 'search_screen.dart';

/// 套餐 tab —— 种草浏览：场景差异化 + 搜索 + 信任带 + featured大卡 + 排序 + 互动
class PackageTabScreen extends StatefulWidget {
  const PackageTabScreen({super.key});

  @override
  State<PackageTabScreen> createState() => _PackageTabScreenState();
}

class _Pkg {
  final String show, dateVenue, ticket, hotel, deal;
  final int price, single, seed;
  final String upgrade; // 独家:房型升级说明
  final String social; // 社会证明标签
  const _Pkg(this.show, this.dateVenue, this.price, this.seed, this.deal,
      this.ticket, this.hotel, this.single,
      {this.upgrade = '房型免费升级 + 双早', this.social = ''});
  int get save => single - price;
}

class _PackageTabScreenState extends State<PackageTabScreen> {
  int _scene = 0;
  int _sort = 0;

  static const _scenes = [
    [LucideIcons.heart, '情侣首选', '双人甜蜜观演'],
    [LucideIcons.user, '单人省心', '一人也精彩'],
    [LucideIcons.crown, 'VIP 体验', '内场+五星'],
    [LucideIcons.users, '家庭出游', '亲子多人'],
  ];
  static const _sorts = ['推荐', '低价优先', '省得多', '近期开场'];

  // 场景差异化套餐库
  static const Map<int, List<_Pkg>> _sceneData = {
    0: [ // 情侣
      _Pkg('周杰伦 嘉年华巡演', '08/29 · 启德体育园', 6360, 0, '',
          '内场企位×2', '尖沙咀凯悦·海景大床2晚', 7200,
          upgrade: '大床房免费升海景房 + 双人早餐', social: '90% 情侣都选这套'),
      _Pkg('MIRROR 演唱会', '09/07 · 亚洲博览馆', 5180, 3, '',
          'A区×2', '红磡海景·大床2晚', 5800,
          upgrade: '标准房免费升海景大床 + 双早'),
      _Pkg('陈奕迅 FEAR', '09/28 · 红磡体育馆', 4880, 2, '限时',
          'B区×2', '尖沙咀凯悦·大床2晚', 5400,
          upgrade: '房型免费升级 + 双早'),
    ],
    1: [ // 单人
      _Pkg('邓紫棋 G.E.M.', '08/30 · 香港体育馆', 2680, 1, '8.5折',
          'A区×1', '旺角智选·单人1晚', 3100,
          upgrade: '免费升高级房 + 单人早餐', social: '单人观演热门之选'),
      _Pkg('林俊杰 JJ20', '09/14 · 亚洲博览馆', 2980, 4, '',
          'B区×1', '红磡海景·单人1晚', 3400,
          upgrade: '免费升海景房 + 早餐'),
    ],
    2: [ // VIP
      _Pkg('周杰伦 嘉年华巡演', '08/29 · 启德体育园', 9800, 0, 'VIP',
          '内场前区×2', '尖沙咀凯悦·维港套房2晚', 11000,
          upgrade: '免费升维港套房 + 行政酒廊', social: 'VIP 首选 · 视野最佳'),
      _Pkg('BLACKPINK', '09/20 · 亚洲博览馆', 8600, 3, 'VIP',
          '内场企位×2', '红磡海景·行政套房2晚', 9800,
          upgrade: '免费升行政套房 + 双早'),
    ],
    3: [ // 家庭
      _Pkg('五月天 好好好', '09/21 · 启德主场馆', 8800, 4, '',
          'A区看台×3', '尖沙咀凯悦·家庭房2晚', 9900,
          upgrade: '免费升家庭房(可住3人) + 三份早餐', social: '亲子家庭优选'),
      _Pkg('陈奕迅 FEAR', '09/28 · 红磡体育馆', 7200, 2, '',
          'B区×3', '旺角智选·家庭房2晚', 8100,
          upgrade: '免费升家庭房 + 三份早餐'),
    ],
  };

  // 场景策展方案(懂你这类人要什么)：[主题贴士icon, 贴士标题, 贴士内容]
  static const _sceneCuration = {
    0: [LucideIcons.wine, '情侣观演 · 小贴士', '含大床/海景房，建议提前到场馆旁餐厅约会，散场人潮期避高峰'],
    1: [LucideIcons.backpack, '单人观演 · 小贴士', '轻装出行，酒店近地铁，看完直接回房，安心不折腾'],
    2: [LucideIcons.crown, 'VIP 体验 · 小贴士', '内场最佳视野 + 套房行政酒廊，专人协助取票，尊享全程'],
    3: [LucideIcons.baby, '家庭出游 · 小贴士', '家庭房可住 3 人，看台连座视野好，含儿童友好早餐'],
  };

  List<_Pkg> get _list {
    final l = [...?_sceneData[_scene]];
    switch (_sort) {
      case 1:
        l.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 2:
        l.sort((a, b) => b.save.compareTo(a.save));
        break;
      case 3:
        break; // mock 近期
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 110),
        children: [
          _header(),
          _sceneRow(),
          // 场景相关内容整块随胶囊切换：淡入 + 横向滑动
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              final slide = Tween<Offset>(
                begin: const Offset(0.10, 0),
                end: Offset.zero,
              ).animate(anim);
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: Column(
              key: ValueKey(_scene),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _curationTip(),
                _listBar(), // 场景标题+套餐数+排序 合并一行
                if (list.isNotEmpty) _featured(list.first),
                ...list.skip(1).map((p) => _pkgCard(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 头部：标题 + 搜索 + 信任细条(合并,精简)
  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('观演套餐',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const Spacer(),
            Row(children: const [
              Icon(LucideIcons.shieldCheck, size: 13, color: AppColors.amber),
              SizedBox(width: 4),
              Text('12.8万张已出票 · 0违约',
                  style: TextStyle(fontSize: 10.5, color: AppColors.amberSoft)),
            ]),
          ]),
          const SizedBox(height: 12),
          PressableScale(
            onTap: () => AppRoute.to(context, const SearchScreen()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0x991C1C1E),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x14FFFFFF))),
              child: Row(children: const [
                Icon(LucideIcons.search,
                    size: 17, color: AppColors.textSecondary),
                SizedBox(width: 10),
                Text('搜艺人 / 演出 · 直接找套餐',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13.5)),
              ]),
            ),
          ),
        ]),
      );

  // ★ 帮我选：不知道怎么选? → 3秒问答直推
  Widget _chooseHelper() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
        child: PressableScale(
          onTap: () => _openQuiz(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0x33E5477B), Color(0x11E5477B)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x66E5477B))),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(11)),
                child: const Icon(LucideIcons.wandSparkles,
                    size: 19, color: AppColors.amberInk),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('不知道怎么选？',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('3 秒回答 · 帮你挑最合适的套餐',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ]),
              ),
              const Icon(LucideIcons.chevronRight,
                  size: 18, color: AppColors.amber),
            ]),
          ),
        ),
      );

  void _openQuiz(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuizSheet(
        scenePkgs: _sceneData,
        onSyncScene: (sceneIdx) => setState(() => _scene = sceneIdx),
      ),
    );
  }

  // 场景策展贴士(懂你这类人要什么)
  Widget _curationTip() {
    final c = _sceneCuration[_scene]!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 2),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Icon(c[0] as IconData, size: 18, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c[1] as String,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(c[2] as String,
                      style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          color: AppColors.textTertiary)),
                ]),
          ),
        ]),
      ),
    );
  }

  // 场景胶囊 tab 横排（参考首页分类风：选中=粉色实心，未选=透明底细边灰字）
  // 左侧渐隐蒙版暗示可横滑；右侧固定筛选按钮
  Widget _sceneRow() => SizedBox(
        height: 40,
        child: Stack(children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 22, right: 58),
            itemCount: _scenes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (_, i) {
              final on = _scene == i;
              return PressableScale(
                onTap: () => setState(() => _scene = i),
                child: AnimatedContainer(
                  // 纯色红块快速切换（无渐变/无投影）
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                      color: on ? const Color(0xFFE5477B) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: on
                              ? const Color(0xFFE5477B)
                              : const Color(0x1FFFFFFF))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_scenes[i][0] as IconData,
                        size: 15,
                        color:
                            on ? AppColors.amberInk : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(_scenes[i][1] as String,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                            color: on
                                ? AppColors.amberInk
                                : AppColors.textTertiary)),
                  ]),
                ),
              );
            },
          ),
          // 左侧渐隐蒙版（暗示左边还有内容可滑）
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.bg, Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
          // 右侧筛选按钮（固定，右侧渐隐蒙版打底）
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(children: [
              IgnorePointer(
                child: Container(
                  width: 24,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [AppColors.bg, Color(0x00000000)],
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.bg,
                padding: const EdgeInsets.only(right: 22),
                child: PressableScale(
                  onTap: () => _openQuiz(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: const Icon(LucideIcons.wandSparkles,
                        size: 18, color: AppColors.amber),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      );

  // 场景标题+套餐数 + 横滑排序 合并一行(精简)
  Widget _listBar() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Row(children: [
          Text(_scenes[_scene][1] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text('· ${_list.length}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
          const Spacer(),
          // 当前排序 + 触发筛选弹窗
          PressableScale(
            onTap: () => _openFilterSheet(context),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.arrowUpDown,
                  size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(_sorts[_sort],
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
            ]),
          ),
        ]),
      );

  // 筛选/排序弹窗（由场景行右侧筛选 icon 与列表栏排序触发）
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (c, setSheet) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
              color: AppColors.bgElevate,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(children: [
              PressableScale(
                onTap: () => Navigator.of(c).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder)),
                  child: const Icon(LucideIcons.chevronLeft,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.arrowUpDown,
                  size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              const Text('排序方式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 16),
            ...List.generate(_sorts.length, (i) {
              final on = _sort == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PressableScale(
                  onTap: () {
                    setState(() => _sort = i);
                    Navigator.of(c).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color:
                            on ? const Color(0x24E5477B) : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: on
                                ? const Color(0x66E5477B)
                                : AppColors.cardBorder)),
                    child: Row(children: [
                      Text(_sorts[i],
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  on ? FontWeight.w800 : FontWeight.w600,
                              color: on
                                  ? AppColors.amber
                                  : AppColors.textPrimary)),
                      const Spacer(),
                      if (on)
                        const Icon(LucideIcons.check,
                            size: 17, color: AppColors.amber),
                    ]),
                  ),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }

  // 由 _Pkg 生成对应演出详情页（拆分 show 为艺人+巡演）
  EventIntroScreen _pkgIntro(_Pkg p) {
    final sp = p.show.indexOf(' ');
    final artist = sp > 0 ? p.show.substring(0, sp) : p.show;
    final subtitle = sp > 0 ? p.show.substring(sp + 1) : '';
    return EventIntroScreen(
      artist: artist,
      subtitle: subtitle,
      venueLine: p.dateVenue,
      dateText: p.dateVenue.split('·').first.trim(),
      venue: p.dateVenue.split('·').last.trim(),
      seed: p.seed,
      showHotel: true,
    );
  }

  // ★ featured 大卡(全出血,编辑感)
  Widget _featured(_Pkg p) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
        child: PressableScale(
          onTap: () => AppRoute.to(context, _pkgIntro(p)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(children: [
              SizedBox(height: 320, width: double.infinity, child: PosterBox(seed: p.seed)),
              Positioned.fill(
                  child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.scrim()))),
              Positioned(
                top: 14,
                left: 14,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('本场景热门',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberInk)),
                  ),
                  if (p.social.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x55FFFFFF))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(LucideIcons.users,
                            size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(p.social,
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ]),
                    ),
                  ],
                ]),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.show, style: AppTheme.displaySerif(size: 26)),
                      const SizedBox(height: 4),
                      Text(p.dateVenue,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFCFCFCF))),
                      const SizedBox(height: 12),
                      // 打包内容行(玻璃底)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                            color: const Color(0x66000000),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Expanded(
                              child: _bundle(LucideIcons.ticket, p.ticket)),
                          Container(
                              width: 1,
                              height: 22,
                              color: const Color(0x33FFFFFF),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                          Expanded(
                              child: _bundle(LucideIcons.bedDouble, p.hotel)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      // 三证据：独家升级 + 省心
                      Row(children: [
                        const Icon(LucideIcons.arrowUp,
                            size: 12, color: AppColors.amber),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('${p.upgrade} · 1 单搞定不用跑 3 个 App',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10.5, color: AppColors.amberSoft)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        RichText(
                            text: TextSpan(
                                text: '套餐 ',
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFCFCFCF)),
                                children: [
                              TextSpan(
                                  text: '¥${p.price}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.amber)),
                              const TextSpan(
                                  text: ' 起',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFFCFCFCF))),
                            ])),
                        const Spacer(),
                        const AmberButton('看套餐',
                            padding: EdgeInsets.symmetric(
                                horizontal: 22, vertical: 11)),
                      ]),
                    ]),
              ),
            ]),
          ),
        ),
      );

  Widget _bundle(IconData icon, String text, {Color color = Colors.white}) =>
      Row(children: [
        Icon(icon, size: 13, color: AppColors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color)),
        ),
      ]);

  // 普通套餐卡
  // 参考「My trips」：全幅大图卡 + 图上渐变遮罩 + 左下标题/日期 + 顶部 deal 角标 + 底部信息条
  Widget _pkgCard(_Pkg p) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
        child: PressableScale(
          onTap: () => AppRoute.to(context, _pkgIntro(p)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.cardBorder)),
              child: Column(children: [
                // ── 顶部大图区 ──
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(fit: StackFit.expand, children: [
                    KenBurns(child: PosterBox(seed: p.seed)),
                    DecoratedBox(
                        decoration: BoxDecoration(gradient: AppColors.scrim())),
                    // 顶部 deal 角标 + 省钱标
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(children: [
                        if (p.deal.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xCCFF785A),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(p.deal,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        const Spacer(),
                        if (p.social.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xB3000000),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(p.social,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.amberBright)),
                          ),
                      ]),
                    ),
                    // 左下标题 + 日期场馆
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.show,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    color: Colors.white)),
                            const SizedBox(height: 5),
                            Row(children: [
                              const Icon(Icons.place_outlined,
                                  size: 13, color: Color(0xFFCFCFCF)),
                              const SizedBox(width: 4),
                              Text(p.dateVenue,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFE0E0E0),
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ]),
                    ),
                  ]),
                ),
                // ── 底部信息条：套餐内容 + 价格/省钱 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bundle(LucideIcons.ticket, p.ticket,
                            color: AppColors.textSecondary),
                        const SizedBox(height: 6),
                        _bundle(LucideIcons.bedDouble, p.hotel,
                            color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Row(children: [
                          RichText(
                              text: TextSpan(
                                  text: '¥${p.price}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.amber),
                                  children: const [
                                TextSpan(
                                    text: ' 起',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textTertiary)),
                              ])),
                          const Spacer(),
                          if (p.save > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0x264EC38A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0x554EC38A))),
                              child: Text('省¥${p.save}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green)),
                            ),
                        ]),
                      ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// 帮我选 · 3题问答(看谁/几人/预算) → 3张推荐滑卡(Tinder式)
class _QuizSheet extends StatefulWidget {
  final Map<int, List<_Pkg>> scenePkgs;
  final void Function(int sceneIdx) onSyncScene;
  const _QuizSheet({required this.scenePkgs, required this.onSyncScene});
  @override
  State<_QuizSheet> createState() => _QuizSheetState();
}

class _QuizSheetState extends State<_QuizSheet> {
  int _step = 0; // 0看谁 1几人 2预算 3=推荐结果
  String _artistText = ''; // 看谁(可输入可选)
  int? _people;
  int? _budget;

  static const _hotArtists = ['周杰伦', 'MIRROR', '邓紫棋', '五月天', '陈奕迅', 'BLACKPINK'];

  // 推导场景
  int _resolveScene() {
    if (_people == 2) return 3;
    if (_budget == 2) return 2;
    if (_people == 0) return 1;
    return 0;
  }

  // 生成推荐：优先所选艺人的套餐(跨场景搜),再补本场景其他
  late List<_Pkg> _recs;
  void _buildRecs() {
    final scene = _resolveScene();
    final all = widget.scenePkgs.values.expand((e) => e).toList();
    final pool = <_Pkg>[];
    // 1. 先放匹配"看谁"的(所有场景中该艺人的套餐)
    if (_artistText.trim().isNotEmpty) {
      for (final p in all) {
        if (p.show.contains(_artistText.trim()) && !pool.contains(p)) {
          pool.add(p);
        }
      }
    }
    // 2. 补本场景套餐
    for (final p in [...?widget.scenePkgs[scene]]) {
      if (!pool.contains(p)) pool.add(p);
    }
    // 3. 跨场景兜底补足到3
    for (final p in all) {
      if (pool.length >= 3) break;
      if (!pool.contains(p)) pool.add(p);
    }
    _recs = pool.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
            color: AppColors.bgElevate,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder)),
        child: _step < 3 ? _quiz() : _resultList(),
      ),
    );
  }

  // ── 问卷（单页：3 个问题全展示，不分步）──
  Widget _quiz() {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: const [
          Icon(LucideIcons.wandSparkles, size: 18, color: AppColors.amber),
          SizedBox(width: 8),
          Text('帮你选套餐',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 18),
        // Q1 看谁
        _q('想看谁的演出？'),
        _artistSearch(),
        const SizedBox(height: 18),
        // Q2 几人
        _q('几个人去看？'),
        _opt('我一个人', 0, _people, (v) => setState(() => _people = v)),
        _opt('两个人（情侣/朋友）', 1, _people,
            (v) => setState(() => _people = v)),
        _opt('3 人及以上（家庭/团体）', 2, _people,
            (v) => setState(() => _people = v)),
        const SizedBox(height: 18),
        // Q3 预算
        _q('住宿预算偏好？'),
        _opt('经济实惠就好', 0, _budget, (v) => setState(() => _budget = v)),
        _opt('舒适为主', 1, _budget, (v) => setState(() => _budget = v)),
        _opt('要尊享 · 内场+五星套房', 2, _budget,
            (v) => setState(() => _budget = v)),
        const SizedBox(height: 20),
        PressableScale(
          onTap: () {
            _buildRecs();
            widget.onSyncScene(_resolveScene());
            Navigator.of(context).pop(); // 关闭问卷弹窗
            AppRoute.to(
                context,
                _QuizResultScreen(
                    recs: List<_Pkg>.from(_recs), artistText: _artistText));
          },
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.amberGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x59E5477B),
                    blurRadius: 20,
                    offset: Offset(0, 8)),
              ],
            ),
            child: const Text('确定',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.amberInk)),
          ),
        ),
      ]),
    );
  }

  // ── 看谁：搜索输入 + 热门 chip ──
  Widget _artistSearch() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _artistText = v),
            controller: TextEditingController(text: _artistText)
              ..selection =
                  TextSelection.collapsed(offset: _artistText.length),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '输入艺人名，如 周杰伦',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppColors.textFaint),
              prefixIcon: const Icon(LucideIcons.search,
                  size: 18, color: AppColors.textSecondary),
              isDense: true,
              filled: true,
              fillColor: AppColors.card,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.amber)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('热门',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotArtists.map((a) {
              final on = _artistText == a;
              return PressableScale(
                onTap: () => setState(() => _artistText = a),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: on ? const Color(0x1FE5477B) : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: on
                              ? const Color(0x99E5477B)
                              : AppColors.cardBorder,
                          width: on ? 1.5 : 1)),
                  child: Text(a,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color:
                              on ? AppColors.amber : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
        ],
      );

  // ── 推荐结果：竖排列表(都关联所选艺人) ──
  Widget _resultList() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        const Icon(LucideIcons.sparkles, size: 18, color: AppColors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
              _artistText.trim().isEmpty
                  ? '为你推荐'
                  : '「$_artistText」为你推荐',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        PressableScale(
          onTap: () => setState(() => _step = 0),
          child: const Text('重新选',
              style: TextStyle(fontSize: 12, color: AppColors.amber)),
        ),
      ]),
      const SizedBox(height: 14),
      Flexible(
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _recs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _recRow(_recs[i], i == 0),
        ),
      ),
    ]);
  }

  Widget _recRow(_Pkg p, bool best) => PressableScale(
        onTap: () {
          Navigator.of(context).pop();
          final sp = p.show.indexOf(' ');
          AppRoute.to(
              context,
              EventIntroScreen(
                artist: sp > 0 ? p.show.substring(0, sp) : p.show,
                subtitle: sp > 0 ? p.show.substring(sp + 1) : '',
                venueLine: p.dateVenue,
                dateText: p.dateVenue.split('·').first.trim(),
                venue: p.dateVenue.split('·').last.trim(),
                seed: p.seed,
                showHotel: true,
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: best ? const Color(0x99E5477B) : AppColors.cardBorder,
                  width: best ? 1.5 : 1),
              boxShadow: best
                  ? const [
                      BoxShadow(
                          color: Color(0x22E5477B),
                          blurRadius: 16,
                          offset: Offset(0, 4))
                    ]
                  : null),
          child: Column(children: [
            // 顶部横幅图
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(17)),
              child: SizedBox(
                height: 96,
                child: Stack(fit: StackFit.expand, children: [
                  PosterBox(seed: p.seed),
                  DecoratedBox(
                      decoration:
                          BoxDecoration(gradient: AppColors.scrim())),
                  if (best)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: const [
                          Icon(LucideIcons.sparkles,
                              size: 10, color: AppColors.amberInk),
                          SizedBox(width: 3),
                          Text('最匹配你',
                              style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amberInk)),
                        ]),
                      ),
                    ),
                  if (p.save > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xCC4EC38A),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('省¥${p.save}',
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 10,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.show,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.displaySerif(size: 18)),
                          const SizedBox(height: 2),
                          Text(p.dateVenue,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFFCFCFCF))),
                        ]),
                  ),
                ]),
              ),
            ),
            // 下方信息：票/酒店各一行 + 匹配理由 + 价格CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _recRowLine(LucideIcons.ticket, p.ticket),
                    const SizedBox(height: 6),
                    _recRowLine(LucideIcons.bedDouble, p.hotel),
                    const SizedBox(height: 10),
                    // 匹配理由高亮条
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: const Color(0x14E5477B),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(LucideIcons.wandSparkles,
                            size: 12, color: AppColors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('为你精选 · ${p.upgrade}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.amberSoft)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      RichText(
                          text: TextSpan(
                              text: '套餐 ',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary),
                              children: [
                            TextSpan(
                                text: '¥${p.price}',
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amber)),
                            const TextSpan(
                                text: ' 起',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary)),
                          ])),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('就选它',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amberInk)),
                      ),
                    ]),
                  ]),
            ),
          ]),
        ),
      );

  Widget _recRowLine(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: AppColors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11.5, color: AppColors.textSecondary)),
        ),
      ]);

  Widget _q(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(t,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _opt(String label, int val, int? sel, ValueChanged<int> onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PressableScale(
          onTap: () => onTap(val),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
                color: sel == val ? const Color(0x1FE5477B) : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel == val
                        ? const Color(0x99E5477B)
                        : AppColors.cardBorder,
                    width: sel == val ? 1.5 : 1)),
            child: Row(children: [
              Icon(
                  sel == val
                      ? LucideIcons.circleCheckBig
                      : LucideIcons.circle,
                  size: 18,
                  color: sel == val ? AppColors.amber : AppColors.textFaint),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

/// 帮我选 · 推荐结果独立页（可返回）
class _QuizResultScreen extends StatelessWidget {
  final List<_Pkg> recs;
  final String artistText;
  const _QuizResultScreen({required this.recs, required this.artistText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // 顶部返回栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(children: [
              PressableScale(
                onTap: () => Navigator.of(context).maybePop(),
                ensureHitArea: true,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder)),
                  child: const Icon(LucideIcons.chevronLeft,
                      size: 20, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(children: [
                  const Icon(LucideIcons.sparkles,
                      size: 18, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        artistText.trim().isEmpty
                            ? '为你推荐'
                            : '「$artistText」为你推荐',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: recs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _recCard(context, recs[i], i == 0)
                  .animate()
                  .fadeIn(duration: 320.ms, delay: (i * 60).ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: AppColors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
      ]);

  Widget _recCard(BuildContext context, _Pkg p, bool best) => PressableScale(
        onTap: () {
          final sp = p.show.indexOf(' ');
          AppRoute.to(
              context,
              EventIntroScreen(
                artist: sp > 0 ? p.show.substring(0, sp) : p.show,
                subtitle: sp > 0 ? p.show.substring(sp + 1) : '',
                venueLine: p.dateVenue,
                dateText: p.dateVenue.split('·').first.trim(),
                venue: p.dateVenue.split('·').last.trim(),
                seed: p.seed,
                showHotel: true,
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: best ? const Color(0x99E5477B) : AppColors.cardBorder,
                  width: best ? 1.5 : 1),
              boxShadow: best
                  ? const [
                      BoxShadow(
                          color: Color(0x22E5477B),
                          blurRadius: 16,
                          offset: Offset(0, 4))
                    ]
                  : null),
          child: Column(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
              child: SizedBox(
                height: 150,
                child: Stack(fit: StackFit.expand, children: [
                  KenBurns(child: PosterBox(seed: p.seed)),
                  DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.scrim())),
                  if (best)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: const [
                          Icon(LucideIcons.sparkles,
                              size: 11, color: AppColors.amberInk),
                          SizedBox(width: 4),
                          Text('最匹配你',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amberInk)),
                        ]),
                      ),
                    ),
                  if (p.save > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xCC4EC38A),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('省¥${p.save}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.show,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 3),
                          Text(p.dateVenue,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFCFCFCF))),
                        ]),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(LucideIcons.ticket, p.ticket),
                    const SizedBox(height: 6),
                    _line(LucideIcons.bedDouble, p.hotel),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: const Color(0x14E5477B),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(LucideIcons.wandSparkles,
                            size: 12, color: AppColors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('为你精选 · ${p.upgrade}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10.5, color: AppColors.amberSoft)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      RichText(
                          text: TextSpan(
                              text: '套餐 ',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary),
                              children: [
                            TextSpan(
                                text: '¥${p.price}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amber)),
                            const TextSpan(
                                text: ' 起',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary)),
                          ])),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(22)),
                        child: const Text('就选它',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amberInk)),
                      ),
                    ]),
                  ]),
            ),
          ]),
        ),
      );
}
