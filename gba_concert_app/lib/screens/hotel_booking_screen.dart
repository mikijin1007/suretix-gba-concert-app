import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'hotel_detail_screen.dart';

/// 酒店预订详情 —— 订单内的住宿凭证:入住信息、房型、政策、联系。
class HotelBookingScreen extends StatelessWidget {
  final String hotel;
  final String roomType;
  final String checkIn;
  final String checkOut;
  final int nights;
  final int guests;
  final String confirmNo;

  const HotelBookingScreen({
    super.key,
    this.hotel = '尖沙咀凯悦酒店',
    this.roomType = '豪华海景房',
    this.checkIn = '2026/09/07 周一',
    this.checkOut = '2026/09/09 周三',
    this.nights = 2,
    this.guests = 2,
    this.confirmNo = 'HTL20260907XY',
  });

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('酒店预订详情',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // 确认状态卡
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0x334EC38A), Color(0x0D4EC38A)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x554EC38A))),
            child: Row(children: [
              const Icon(LucideIcons.circleCheckBig,
                  size: 28, color: AppColors.green),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('预订已确认',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                      const SizedBox(height: 4),
                      Text('确认号 $confirmNo',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          // 酒店与房型
          _card([
            // 酒店照片 + 名称,箭头在最右,点击进酒店介绍页
            PressableScale(
              onTap: () =>
                  AppRoute.to(context, HotelDetailScreen(hotel: kHotels[0])),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/hotel_1.jpg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      color: AppColors.bgElevate,
                      child: const Icon(LucideIcons.bedDouble,
                          size: 20, color: AppColors.amber),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hotel,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('$roomType · 含双早',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary)),
                      ]),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronRight,
                    size: 18, color: AppColors.textFaint),
              ]),
            ),
            const SizedBox(height: 8),
            // 地址 + 复制
            Row(children: [
              const Expanded(
                child: Text('香港九龙尖沙咀河内道 18 号(近港铁尖沙咀站 · 距场馆约 12 分钟车程)',
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textTertiary)),
              ),
              const SizedBox(width: 8),
              PressableScale(
                ensureHitArea: true,
                onTap: () => _toast(context, '酒店地址已复制'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.bgElevate,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.cardBorder)),
                  child: const Text('复制',
                      style: TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary)),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            // 三枚操作胶囊
            Row(children: [
              _pill(context, LucideIcons.train, '交通订票',
                  () => _toast(context, '正在为你查询前往酒店的交通')),
              const SizedBox(width: 8),
              _pill(context, LucideIcons.mapPin, '地图',
                  () => _toast(context, '正在打开地图导航')),
              const SizedBox(width: 8),
              _pill(context, LucideIcons.phone, '联系酒店',
                  () => _toast(context, '正在呼出 +852 2311 1234')),
            ]),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 16),
            // 入住/退房
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('入住',
                          style: TextStyle(
                              fontSize: 10.5, color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Text(checkIn,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text('15:00 后',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textFaint)),
                    ]),
              ),
              Column(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$nights 晚',
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                ),
                const SizedBox(height: 4),
                const Icon(LucideIcons.arrowRight,
                    size: 14, color: AppColors.textFaint),
              ]),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('退房',
                          style: TextStyle(
                              fontSize: 10.5, color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Text(checkOut,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text('12:00 前',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textFaint)),
                    ]),
              ),
            ]),
          ]),
          const SizedBox(height: 14),
          // 入住信息
          _sectionTitle('入住信息'),
          _card([
            _kv('入住人', '王小明'),
            _kv('入住人数', '$guests 位成人'),
            _kv('房间数量', '1 间'),
            _kv('早餐', '含双早(6:30–10:30)'),
            _kv('床型', '1 张大床'),
            _kv('特殊要求', '高层安静房(以酒店实际安排为准)'),
          ]),
          const SizedBox(height: 14),
          // 预计到店
          _sectionTitle('预计到店'),
          _card([
            Row(children: [
              const Icon(LucideIcons.clock, size: 15, color: AppColors.amber),
              const SizedBox(width: 8),
              Text('$checkIn 15:00 之前',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            const Text('如需提前到店或延后入住,请联系酒店前台(不影响酒店留房)。',
                style: TextStyle(
                    fontSize: 11, height: 1.6, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 14),
          // 订单信息
          _sectionTitle('订单信息'),
          _card([
            _kvCopy(context, '订单号', 'ST202609071206'),
            _kvCopy(context, '确认号', confirmNo),
            _kv('下单时间', '2026-08-27 23:40'),
            _kv('支付方式', '套餐一价全含(已支付)'),
          ]),
          const SizedBox(height: 14),
          // 退改政策
          _sectionTitle('退改政策'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.28))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('入住前 24 小时可免费取消',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                  SizedBox(height: 8),
                  Text('· 入住前 24 小时以外取消:全额退款,1–5 个工作日到账\n· 入住前 24 小时内取消:扣首晚房费\n· 未入住(No-show):不予退款\n· 因演出取消导致的住宿取消:平台协助全额退',
                      style: TextStyle(
                          fontSize: 11.5,
                          height: 1.7,
                          color: AppColors.textSecondary)),
                ]),
          ),
        ],
      ),
    );
  }

  // 操作胶囊(交通订票 / 地图 / 联系酒店)
  Widget _pill(BuildContext context, IconData icon, String label,
          VoidCallback onTap) =>
      Expanded(
        child: PressableScale(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.bgElevate,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 13, color: AppColors.amber),
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
            ]),
          ),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
        child: Text(t,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  // 带「复制」的键值行
  Widget _kvCopy(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          SizedBox(
            width: 66,
            child: Text(k,
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          PressableScale(
            ensureHitArea: true,
            onTap: () => _toast(context, '$k已复制'),
            child: const Text('复制',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amber)),
          ),
        ]),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 66,
            child: Text(k,
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
        ]),
      );
}
