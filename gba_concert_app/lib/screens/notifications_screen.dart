import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 消息通知 —— 出票/订单/活动三类 + 出票成功高亮。后端接口预留。
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0;
  static const _tabs = ['全部', '出票', '订单', '活动'];

  // [类型(0出票/1订单/2活动), 标题, 内容, 时间, 是否未读]
  final List<List<Object>> _all = [
    [0, '出票成功 · 实体票已上传', '周杰伦 嘉年华巡演 08/29 的实体票已出票,点此查看实拍照与物流。', '10 分钟前', true],
    [1, '订单已支付', '订单 ST202608291 已支付成功,套餐合计 ¥6,360,进入待出票。', '2 小时前', true],
    [2, '专属优惠券到账', '你的观演礼包已发放 4 张权益券,查看钱包立即使用。', '昨天 20:14', false],
    [1, '顺丰已揽收', '实体票已由顺丰揽收,预计明天送达,单号 SF1234567890。', '昨天 15:30', false],
    [2, 'BLACKPINK 世界巡演开票提醒', '你关注的 BLACKPINK 11/02 启德场明天 12:00 开票。', '3 天前', false],
  ];

  int get _unreadCount => _all.where((e) => e[4] == true).length;

  void _markAllRead() {
    if (_unreadCount == 0) return;
    setState(() {
      for (final e in _all) {
        e[4] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('已将全部消息标为已读'),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  List<List<Object>> get _list {
    if (_tab == 0) return _all;
    final t = _tab - 1;
    return _all.where((e) => e[0] == t).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('消息通知',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PressableScale(
              ensureHitArea: true,
              onTap: _unreadCount > 0 ? _markAllRead : null,
              child: Opacity(
                opacity: _unreadCount > 0 ? 1 : 0.4,
                child: Text(
                    _unreadCount > 0 ? '全部已读 ($_unreadCount)' : '全部已读',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.amber)),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _tabBar(),
        Expanded(child: _list.isEmpty ? _empty(context) : _listView()),
      ]),
    );
  }

  Widget _tabBar() => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
            children: List.generate(_tabs.length, (i) {
          final on = _tab == i;
          return PressableScale(
            onTap: () => setState(() => _tab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                  gradient: on ? AppColors.amberGradient : null,
                  color: on ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: on ? Colors.transparent : AppColors.cardBorder)),
              child: Text(_tabs[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: on ? AppColors.amberInk : AppColors.textSecondary)),
            ),
          );
        })),
      );

  Widget _listView() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        itemCount: _list.length,
        itemBuilder: (_, i) => _card(_list[i]),
      );

  Widget _card(List<Object> e) {
    final type = e[0] as int;
    final unread = e[4] as bool;
    final isIssued = type == 0;
    final icon = type == 0
        ? LucideIcons.ticketCheck
        : (type == 1 ? LucideIcons.package : LucideIcons.gift);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isIssued
                    ? AppColors.green.withValues(alpha: 0.5)
                    : AppColors.cardBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: (isIssued ? AppColors.green : AppColors.amber)
                    .withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon,
                size: 18, color: isIssued ? AppColors.green : AppColors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(e[1] as String,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isIssued
                                  ? AppColors.green
                                  : AppColors.textPrimary)),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.deal, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 6),
                  Text(e[2] as String,
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(e[3] as String,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textFaint)),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.bellRing, size: 42, color: AppColors.amber),
            const SizedBox(height: 14),
            const Text('消息都会出现在这里',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('出票进度、物流动态、开票提醒和专属优惠,都会第一时间通知你,不错过任何一场演出。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            PressableScale(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(24)),
                child: const Text('去看看演出',
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
