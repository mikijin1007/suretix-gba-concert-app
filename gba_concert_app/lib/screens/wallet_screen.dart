import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 优惠券 / 礼品卡 —— 可用/已用/过期 + 礼品卡余额。后端接口预留。
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _tab = 0;
  static const _tabs = ['可用', '已用', '已过期'];


  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  // [面值, 类型描述, 门槛, 有效期, 状态(0可用/1已用/2过期)]
  static const _coupons = [
    [200, '购票立减券', '满 2000 可用', '2026/12/31 到期', 0],
    [80, '餐饮优惠券', '场馆周边餐厅通用', '2026/10/15 到期', 0],
    [50, '酒店早餐券', '合作酒店可用', '2026/11/30 到期', 0],
    [100, '购票立减券', '满 1500 可用', '已于 08/12 使用', 1],
    [30, '周边折扣券', '官方周边商城', '2026/07/01 已过期', 2],
  ];

  List<List<Object>> get _list =>
      _coupons.where((c) => c[4] == _tab).toList().cast<List<Object>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('我的优惠券',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        _tabBar(),
        Expanded(child: _list.isEmpty ? _empty() : _listView()),
      ]),
    );
  }

  Widget _tabBar() => Container(
        height: 48,
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: _list.length,
        itemBuilder: (_, i) => _couponCard(_list[i]),
      );

  Widget _couponCard(List<Object> c) {
    final usable = c[4] == 0;
    final main = usable ? AppColors.amber : AppColors.textFaint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          // 左侧面值
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: AppColors.line,
                        width: 1))),
            child: Column(children: [
              RichText(
                  text: TextSpan(
                      text: '¥',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: main),
                      children: [
                    TextSpan(
                        text: '${c[0]}',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: main))
                  ])),
              const SizedBox(height: 2),
              Text(c[2] as String,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textFaint)),
            ]),
          ),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c[1] as String,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(c[3] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ]),
            ),
          ),
          if (usable)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: PressableScale(
                onTap: () {
                  Navigator.of(context).maybePop();
                  _toast('已为你返回,选好演出后在结算页使用该券');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      borderRadius: BorderRadius.circular(18)),
                  child: const Text('去使用',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amberInk)),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(c[4] == 1 ? '已使用' : '已过期',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textFaint)),
            ),
        ]),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.ticketX, size: 42, color: AppColors.textFaint),
          SizedBox(height: 14),
          Text('这里还没有券',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      );
}
