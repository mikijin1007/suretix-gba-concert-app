import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 酒店详情页 —— 选中某家酒店后进入，展示该酒店的房型/设施/位置(数据驱动)
class HotelData {
  final String name;
  final int star;
  final int imgIdx; // hotel_N.jpg
  final String room; // 升级房型
  final String roomSpec; // 面积/床型/可住
  final List<String> roomFeats;
  final String dist;
  final List<List<Object>> facilities; // [icon, label]
  final List<List<String>> nearby; // [label, value]
  const HotelData({
    required this.name,
    required this.star,
    required this.imgIdx,
    required this.room,
    required this.roomSpec,
    required this.roomFeats,
    required this.dist,
    required this.facilities,
    required this.nearby,
  });
}

/// 酒店库（配置页/详情页共用，index 对齐 _hotels）
const kHotels = <HotelData>[
  HotelData(
    name: '尖沙咀凯悦',
    star: 5,
    imgIdx: 1,
    room: '豪华海景房（升级）+ 双早',
    roomSpec: '42㎡ · 1 张特大床 · 可住 2 人',
    roomFeats: ['维港海景落地窗', '含双人自助早餐', '免费高速 WiFi', '24h 健身房'],
    dist: '距场馆 15 分钟',
    facilities: [
      [LucideIcons.waves, '室内泳池'],
      [LucideIcons.dumbbell, '健身房'],
      [LucideIcons.utensils, '餐厅酒吧'],
      [LucideIcons.wifi, '免费WiFi'],
      [LucideIcons.car, '停车场'],
      [LucideIcons.coffee, '双人早餐'],
    ],
    nearby: [
      ['距启德体育园', '步行 15 分钟 / 打车 5 分钟'],
      ['尖沙咀地铁站', '步行 3 分钟'],
      ['海港城商圈', '步行 5 分钟'],
    ],
  ),
  HotelData(
    name: '红磡海景酒店',
    star: 4,
    imgIdx: 2,
    room: '海景双床房（升级）+ 双早',
    roomSpec: '32㎡ · 2 张单人床 · 可住 2 人',
    roomFeats: ['海景阳台', '含双人早餐', '免费 WiFi', '近红磡站'],
    dist: '步行 10 分钟直达',
    facilities: [
      [LucideIcons.utensils, '餐厅'],
      [LucideIcons.wifi, '免费WiFi'],
      [LucideIcons.car, '停车场'],
      [LucideIcons.coffee, '双人早餐'],
      [LucideIcons.shirt, '洗衣服务'],
      [LucideIcons.bellRing, '24h前台'],
    ],
    nearby: [
      ['距启德体育园', '步行 10 分钟'],
      ['红磡地铁站', '步行 5 分钟'],
      ['黄埔商场', '步行 8 分钟'],
    ],
  ),
  HotelData(
    name: '旺角智选假日',
    star: 4,
    imgIdx: 3,
    room: '高级双床房（升级）+ 双早',
    roomSpec: '26㎡ · 2 张单人床 · 可住 2 人',
    roomFeats: ['市景房', '含双人早餐', '免费 WiFi', '近地铁'],
    dist: '地铁 2 站',
    facilities: [
      [LucideIcons.utensils, '餐厅'],
      [LucideIcons.wifi, '免费WiFi'],
      [LucideIcons.coffee, '双人早餐'],
      [LucideIcons.bellRing, '24h前台'],
      [LucideIcons.shirt, '洗衣服务'],
      [LucideIcons.dumbbell, '健身房'],
    ],
    nearby: [
      ['距启德体育园', '地铁 2 站 / 打车 12 分钟'],
      ['旺角地铁站', '步行 2 分钟'],
      ['朗豪坊', '步行 5 分钟'],
    ],
  ),
];

class HotelDetailScreen extends StatelessWidget {
  final HotelData hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        ListView(padding: const EdgeInsets.only(bottom: 30), children: [
          // hero 酒店大图
          SizedBox(
            height: 260,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/hotel_${hotel.imgIdx}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.bgElevate)),
              DecoratedBox(decoration: BoxDecoration(gradient: AppColors.scrim())),
              Positioned(
                left: 22,
                right: 22,
                bottom: 20,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('套餐含此酒店 · 房型升级+双早',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amberInk)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Text(hotel.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        Row(
                            children: List.generate(
                                hotel.star,
                                (_) => const Icon(LucideIcons.star,
                                    size: 12, color: AppColors.amber))),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: Color(0xFFCFCFCF)),
                        const SizedBox(width: 4),
                        Text(hotel.dist,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFCFCFCF))),
                      ]),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          _head('套餐房型'),
          _roomCard(),
          _head('酒店设施'),
          _facilityGrid(),
          _head('位置与周边'),
          _locationCard(),
        ]),
        // 顶部返回
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: PressableScale(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                    color: Color(0xB3000000), shape: BoxShape.circle),
                child: const Icon(LucideIcons.chevronLeft,
                    size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _head(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Text(t,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );

  Widget _roomCard() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
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
                height: 150,
                child: Image.asset('assets/images/hotel_5.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.bgElevate)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel.room,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(hotel.roomSpec,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: hotel.roomFeats
                            .map((f) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.bgElevate,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(f,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary)),
                                ))
                            .toList()),
                  ]),
            ),
          ]),
        ),
      );

  Widget _facilityGrid() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: hotel.facilities.map((it) {
            return SizedBox(
              width: (390 - 44 - 20) / 3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Column(children: [
                  Icon(it[0] as IconData, size: 18, color: AppColors.amber),
                  const SizedBox(height: 6),
                  Text(it[1] as String,
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary)),
                ]),
              ),
            );
          }).toList(),
        ),
      );

  Widget _locationCard() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 120,
                color: AppColors.bgElevate,
                child: Stack(fit: StackFit.expand, children: const [
                  Center(
                      child: Icon(LucideIcons.map,
                          size: 32, color: AppColors.textFaint)),
                  Center(
                      child: Icon(LucideIcons.mapPin,
                          size: 26, color: AppColors.amber)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  children: hotel.nearby
                      .map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              const Icon(LucideIcons.mapPin,
                                  size: 14, color: AppColors.amber),
                              const SizedBox(width: 10),
                              Text(n[0],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const Spacer(),
                              Text(n[1],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ))
                      .toList()),
            ),
          ]),
        ),
      );
}
