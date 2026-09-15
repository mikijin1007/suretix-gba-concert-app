import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'event_intro_screen.dart';

/// 我的收藏 —— 收藏的演出。支持取消收藏(含撤销)。
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // [演出名, 场馆日期, 最低价, 状态(0现票/1紧张), seed]
  final List<List<Object>> _favs = [
    ['周杰伦 嘉年华巡演', '香港 · 启德体育园 · 08/29', 2180, 1, 0],
    ['邓紫棋 G.E.M. 世界巡演', '香港体育馆 · 09/12', 1880, 0, 1],
    ['陈奕迅 FEAR&DREAMS', '红磡体育馆 · 10/15', 2080, 0, 4],
  ];

  // 取消收藏(可撤销)
  void _unfav(int i) {
    final removed = _favs[i];
    setState(() => _favs.removeAt(i));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已取消收藏「${removed[0]}」'),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '撤销',
        textColor: AppColors.amber,
        onPressed: () => setState(() => _favs.insert(i, removed)),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('我的收藏',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: _favs.isEmpty
          ? _empty(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              itemCount: _favs.length,
              itemBuilder: (_, i) => _card(context, _favs[i], i),
            ),
    );
  }

  Widget _card(BuildContext context, List<Object> e, int index) {
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
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
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
                            color: (status == 1
                                    ? AppColors.deal
                                    : AppColors.green)
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(status == 1 ? '仅剩少量' : '現票充足',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: status == 1
                                    ? AppColors.deal
                                    : AppColors.green)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PressableScale(
                ensureHitArea: true,
                onTap: () => _unfav(index),
                child: const Icon(LucideIcons.heart,
                    size: 18, color: AppColors.deal),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.heart, size: 42, color: AppColors.amber),
            const SizedBox(height: 14),
            const Text('收藏你想看的演出',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('把心仪的演唱会收藏在这里,开票、降价第一时间提醒你,不错过每一场。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            PressableScale(
              onTap: () {
                Navigator.of(context).maybePop();
                MainShell.go(context, 1);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(24)),
                child: const Text('去逛热门演出',
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
