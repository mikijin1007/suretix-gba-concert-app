import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'package_builder_screen.dart';

/// 演出详情页 —— 套餐主入口 + 现票/担保如实区分 (对齐 PRD + Design DNA)
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _session = 0;
  int _buyMode = 0; // 0=按票档 1=按位置(同页内联选座)
  int _seatZone = 1; // 选中区域: 0内场 1=A区 2=B区 3=C区(售罄) 4=D区
  int _viewTab = 0; // 往期视角 tab
  int _priceTier = 0; // 选中的票档价格档位(大麦版式)
  final Set<String> _pickedSeats = {}; // 已选具体座位 "排-座"

  // 票档价格表 [价格, 名称, 余票, 对应位置区域idx]
  static const _priceTiers = [
    [280, '看台 D 区', 30, 4],
    [580, 'B 区看台', 30, 2],
    [680, 'A 区看台', 4, 1],
    [880, '内场企位', 8, 0],
    [1280, 'VIP 内场', 6, 0],
  ];

  // 场次
  static const _sessions = [
    ['08/29', '周五'],
    ['08/30', '周六'],
    ['08/31', '周日'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _hero(),
            const SizedBox(height: 18),
            _sessionPicker(),
            _infoRow(),
            _sectionTitle('选择门票', '选票档 · 看位置 · 确认价格'),
            ..._damaiTicketModule(),
            _guaranteeBlock(),
            const SizedBox(height: 120),
          ],
        ),
        _backButton(),
        _stickyBar(),
      ]),
    );
  }

  // ── 全出血海报 hero ──
  Widget _hero() => SizedBox(
        height: 380,
        child: Stack(fit: StackFit.expand, children: [
          const KenBurns(child: PosterBox(seed: 0)),
          DecoratedBox(decoration: BoxDecoration(gradient: AppColors.scrim())),
          Positioned(
            left: 22,
            right: 22,
            bottom: 24,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0x99000000),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('官方售罄 · 我们仍有票',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amber)),
                  ),
                  const SizedBox(height: 10),
                  Text('周杰伦', style: AppTheme.displaySerif(size: 38)),
                  Text('嘉年华巡演 2026',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary.withValues(alpha: 0.9))),
                  const SizedBox(height: 10),
                  Row(children: const [
                    Icon(LucideIcons.mapPin, size: 13, color: Color(0xFFCFCFCF)),
                    SizedBox(width: 5),
                    Text('香港 · 启德体育园主场馆',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFCFCFCF))),
                  ]),
                ]),
          ),
        ]),
      );

  Widget _backButton() => Positioned(
        top: 16,
        left: 16,
        child: SafeArea(
          child: PressableScale(
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
      );

  // ── 场次选择 ──
  Widget _sessionPicker() => SizedBox(
        height: 62,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: _sessions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final on = i == _session;
            return PressableScale(
              onTap: () => setState(() => _session = i),
              child: Container(
                width: 66,
                decoration: BoxDecoration(
                    gradient: on ? AppColors.amberGradient : null,
                    color: on ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: on
                        ? null
                        : Border.all(color: AppColors.cardBorder)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_sessions[i][0],
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color:
                                  on ? AppColors.amberInk : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(_sessions[i][1],
                          style: TextStyle(
                              fontSize: 10,
                              color: on
                                  ? AppColors.amberInk
                                  : AppColors.textTertiary)),
                    ]),
              ),
            );
          },
        ),
      );

  Widget _infoRow() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
        child: Row(children: const [
          _InfoChip(LucideIcons.clock, '20:00 开演'),
          SizedBox(width: 10),
          _InfoChip(LucideIcons.ticket, '最迟 T-1 18:00 出票'),
        ]),
      );

  Widget _sectionTitle(String zh, String sub) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(zh,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
              ),
            ]),
      );

  // ── 购票双模式切换：按票档 / 按位置 ──
  Widget _buyModeTabs() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            _modeTab('按票档', LucideIcons.listChecks, 0),
            _modeTab('按位置', LucideIcons.armchair, 1),
          ]),
        ),
      );

  Widget _modeTab(String label, IconData icon, int idx) {
    final on = _buyMode == idx;
    return Expanded(
      child: PressableScale(
        onTap: () => setState(() => _buyMode = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              gradient: on ? AppColors.amberGradient : null,
              borderRadius: BorderRadius.circular(11)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 15,
                color: on ? AppColors.amberInk : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: on ? AppColors.amberInk : AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  // ── 套餐（主入口）──
  List<Widget> _packages() {
    final pkgs = [
      ['尊享套餐', '内场企位 + 尖沙咀凯悦 2 晚', '¥6,360', '/2人', true, 1],
      ['标准套餐', 'A区看台 + 红磡海景酒店 2 晚', '¥4,180', '/2人', false, 2],
    ];
    return pkgs
        .map((p) => _packageCard(p[0] as String, p[1] as String,
            p[2] as String, p[3] as String, p[4] as bool, p[5] as int))
        .toList()
        .animate(interval: 60.ms)
        .fadeIn(duration: 340.ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _packageCard(String name, String detail, String price, String unit,
          bool recommend, int seed) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: PressableScale(
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: recommend
                        ? const Color(0x66E5477B)
                        : AppColors.cardBorder)),
            child: Column(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 92,
                  child: Stack(fit: StackFit.expand, children: [
                    PosterBox(seed: seed),
                    DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: AppColors.scrim())),
                    if (recommend)
                      Positioned(
                        top: 10,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              gradient: AppColors.amberGradient,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('情侣首选',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amberInk)),
                        ),
                      ),
                    Positioned(
                        left: 14,
                        bottom: 10,
                        child: Text(name,
                            style: AppTheme.displaySerif(size: 18))),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pkgLine(LucideIcons.ticket, detail.split(' + ')[0]),
                      const SizedBox(height: 6),
                      _pkgLine(LucideIcons.bedDouble,
                          detail.contains(' + ') ? detail.split(' + ')[1] : ''),
                      const SizedBox(height: 6),
                      _pkgLine(LucideIcons.train, '可选加购 · 广深港高铁接送'),
                      const SizedBox(height: 12),
                      Row(children: [
                        RichText(
                            text: TextSpan(
                                text: price,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amber),
                                children: [
                              TextSpan(
                                  text: ' $unit',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary))
                            ])),
                        const Spacer(),
                        const AmberButton('选套餐',
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10)),
                      ]),
                    ]),
              ),
            ]),
          ),
        ),
      );

  Widget _pkgLine(IconData icon, String text) => Row(children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: Color(0xFFCFCFCF))),
        ),
      ]);

  // ── 按位置选座（内联 · 大麦风四面台）──
  // 区域: [名, 余票(-1=充足 0=售罄)]  不裸露单价，价格只在套餐维度算
  static const _zones = [
    ['内场企位', 3],
    ['A区 正面', -1],
    ['B区 正面', -1],
    ['C区 侧面', 0],
  ];

  List<Widget> _seatInline() {
    return [
      // 提示条
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0x1FE5477B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x3DE5477B))),
          child: Row(children: const [
            Icon(LucideIcons.info, size: 14, color: AppColors.amber),
            SizedBox(width: 8),
            Expanded(
              child: Text('选好座位下单 · 多张将优先为您匹配连座，连座不足会温馨提示',
                  style: TextStyle(fontSize: 11, color: AppColors.amberSoft)),
            ),
          ]),
        ),
      ),
      // 区域状态卡（横排4）
      SizedBox(
        height: 66,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: _zones.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _zoneStatusCard(i),
        ),
      ),
      const SizedBox(height: 14),
      // 四面台示意图
      _stageMap(),
      const SizedBox(height: 10),
      _seatLegend(),
      const SizedBox(height: 16),
      // 该区具体座位网格（几排几座）
      _seatGrid(),
      const SizedBox(height: 16),
      // 往期视角参考
      _viewReference(),
    ];
  }

  // ── 该区座位网格：真实排号 N排N座，可点具体空座 + 连座 ──
  Widget _seatGrid() {
    final z = _seatZone < _zones.length ? _zones[_seatZone] : null;
    final soldout = _seatZone == 3 || _seatZone == 4;
    if (soldout || z == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: const Row(children: [
            Icon(LucideIcons.circleOff, size: 16, color: AppColors.textFaint),
            SizedBox(width: 8),
            Text('该区域暂无可选座位',
                style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
          ]),
        ),
      );
    }
    const rows = 8, cols = 12;
    final sold = {'2-4', '2-5', '3-8', '4-6', '4-7', '5-2', '6-9', '6-10', '7-3'};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          Row(children: [
            Text('${z[0]} · 选择座位',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800)),
            const Spacer(),
            const Text('近舞台 →',
                style: TextStyle(fontSize: 10, color: AppColors.amber)),
          ]),
          const SizedBox(height: 12),
          for (int r = 1; r <= rows; r++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(
                    width: 22,
                    child: Text('${r}排',
                        style: const TextStyle(
                            fontSize: 8.5, color: AppColors.textFaint))),
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int c = 1; c <= cols; c++)
                          _seatCell(r, c, sold.contains('$r-$c')),
                      ]),
                ),
              ]),
            ),
          const SizedBox(height: 8),
          _connectPref(),
          if (_pickedSeats.isNotEmpty) ...[
            const SizedBox(height: 10),
            _pickedSeatSummary(z),
          ],
        ]),
      ),
    );
  }

  Widget _seatCell(int r, int c, bool sold) {
    final key = '$r-$c';
    final picked = _pickedSeats.contains(key);
    Color bg;
    Color? border;
    if (sold) {
      bg = const Color(0xFF2A2A2D);
    } else if (picked) {
      bg = AppColors.amber;
    } else {
      bg = const Color(0x334EC38A);
      border = const Color(0x804EC38A);
    }
    return GestureDetector(
      onTap: sold
          ? null
          : () => setState(() {
                if (picked) {
                  _pickedSeats.remove(key);
                } else {
                  _pickedSeats.add(key);
                }
              }),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border) : null),
        child: picked
            ? const Icon(LucideIcons.check, size: 12, color: AppColors.amberInk)
            : null,
      ),
    );
  }

  Widget _connectPref() => Row(children: [
        const Icon(LucideIcons.usersRound, size: 13, color: AppColors.amber),
        const SizedBox(width: 6),
        const Expanded(
          child: Text('点亮相邻座位即可锁定连座 · 已为你按连座优先排列',
              style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
        ),
      ]);

  Widget _pickedSeatSummary(List z) {
    final seats = _pickedSeats.toList()..sort();
    final label = seats.map((s) {
      final p = s.split('-');
      return '${p[0]}排${p[1]}座';
    }).join('、');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0x1FE5477B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x3DE5477B))),
      child: Row(children: [
        Expanded(
          child: Text('已选 ${seats.length} 座 · $label',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amberSoft)),
        ),
        const SizedBox(width: 8),
        const Text('下一步',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.amber)),
      ]),
    );
  }

  Widget _zoneStatusCard(int i) {
    final z = _zones[i];
    final left = z[1] as int;
    final soldout = left == 0;
    final tight = left > 0;
    final on = _seatZone == i;
    final dot = soldout
        ? AppColors.textFaint
        : (tight ? AppColors.deal : AppColors.green);
    return PressableScale(
      onTap: soldout ? null : () => setState(() => _seatZone = i),
      child: Container(
        width: 118,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: on ? const Color(0x1FE5477B) : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: on
                    ? const Color(0x99E5477B)
                    : AppColors.cardBorder,
                width: on ? 1.5 : 1)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(color: dot, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(z[0] as String,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: soldout
                            ? AppColors.textFaint
                            : AppColors.textPrimary)),
              ]),
              const SizedBox(height: 5),
              Text(
                  soldout
                      ? '已售罄'
                      : (tight ? '仅余 $left 张' : '余量充足'),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: soldout
                          ? AppColors.textFaint
                          : (tight ? AppColors.deal : AppColors.textTertiary))),
            ]),
      ),
    );
  }

  // 四面台环形示意
  Widget _stageMap() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            Text('点击区域选座 · 舞台居中 · 示意图仅供参考',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            const SizedBox(height: 14),
            // 北 A区
            _mapZoneBtn(1, '北 · A区 正面'),
            const SizedBox(height: 8),
            Row(children: [
              // 西 C区(售罄)
              Expanded(flex: 2, child: _mapZoneBtn(3, '西·C区')),
              const SizedBox(width: 8),
              // 中间 内场+舞台
              Expanded(
                flex: 3,
                child: Column(children: [
                  _mapZoneBtn(0, '内场企位'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('主 舞 台',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberInk)),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              // 东 D区
              Expanded(flex: 2, child: _mapZoneBtn(4, '东·D区')),
            ]),
            const SizedBox(height: 8),
            // 南 B区
            _mapZoneBtn(2, '南 · B区 正面'),
          ]),
        ),
      );

  Widget _mapZoneBtn(int i, String label) {
    // C区(3)售罄, D区(4)复用C状态示意为售罄
    final soldout = i == 3 || i == 4;
    final on = _seatZone == i;
    final z = i < _zones.length ? _zones[i] : null;
    final tight = z != null && (z[1] as int) > 0;
    Color base;
    if (soldout) {
      base = AppColors.textFaint;
    } else if (tight) {
      base = AppColors.deal;
    } else {
      base = AppColors.green;
    }
    return PressableScale(
      onTap: soldout ? null : () => setState(() => _seatZone = i),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: soldout
                ? const Color(0xFF1E1E20)
                : base.withValues(alpha: on ? 0.4 : 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: soldout
                    ? const Color(0xFF2A2A2D)
                    : base.withValues(alpha: on ? 1 : 0.5),
                width: on ? 1.5 : 1)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: soldout ? AppColors.textFaint : base)),
              if (on)
                Text('✓ 已选',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: base)),
              if (soldout)
                const Text('已售罄',
                    style: TextStyle(
                        fontSize: 9, color: AppColors.textFaint)),
            ]),
      ),
    );
  }

  Widget _seatLegend() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legendDot(AppColors.green, '可选'),
          const SizedBox(width: 14),
          _legendDot(AppColors.amber, '已选'),
          const SizedBox(width: 14),
          _legendDot(AppColors.deal, '紧张'),
          const SizedBox(width: 14),
          _legendDot(AppColors.textFaint, '售罄'),
        ]),
      );

  Widget _legendDot(Color c, String t) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: c))),
        const SizedBox(width: 5),
        Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ]);

  // 往期视角参考（tab 切换 + 大图 + 描述）
  Widget _viewReference() {
    final tabs = [
      ['A区 正面', 2, '正面看台，距主舞台约 15–25 排，视角开阔，大屏清晰可见'],
      ['B区 正面', 3, '正面远端看台，可俯瞰全场，适合看整体舞美'],
      ['内场企位', 1, '距舞台最近，能看清艺人细节，站席体验热烈'],
    ];
    final cur = tabs[_viewTab];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(LucideIcons.camera, size: 15, color: AppColors.amber),
          SizedBox(width: 6),
          Text('往期视角参考',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        Row(
            children: List.generate(tabs.length, (i) {
          final on = i == _viewTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PressableScale(
              onTap: () => setState(() => _viewTab = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: on ? const Color(0x1FE5477B) : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: on
                            ? const Color(0x99E5477B)
                            : AppColors.cardBorder)),
                child: Text(tabs[i][0] as String,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            on ? AppColors.amber : AppColors.textSecondary)),
              ),
            ),
          );
        })),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 170,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/view_${cur[1]}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.card)),
              DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.scrim())),
              Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      color: Color(0x99000000), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.play,
                      size: 20, color: Colors.white),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 12,
                child: Text('${cur[0]} · 视角参考',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Text(cur[2] as String,
            style: const TextStyle(
                fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
      ]),
    );
  }

  // ── 大麦选座版式：顶部票档价格胶囊 → 中间位置图 → 底部价格模块 ──
  List<Widget> _damaiTicketModule() {
    final t = _priceTiers[_priceTier];
    final zoneIdx = t[3] as int;
    // 让位置图/座位网格与选中票档联动
    if (_seatZone != zoneIdx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _seatZone != zoneIdx) setState(() => _seatZone = zoneIdx);
      });
    }
    return [
      // ① 顶部横向票档价格胶囊
      SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: _priceTiers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => _priceChip(i),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: (t[2] as int) <= 6 ? AppColors.deal : AppColors.green,
                  shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('${t[1]} · ${(t[2] as int) <= 6 ? '仅余 ${t[2]} 张' : '余量充足'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
      const SizedBox(height: 14),
      // ② 中间：票档位置示意图
      _stageMap(),
      const SizedBox(height: 10),
      _seatLegend(),
      const SizedBox(height: 16),
      // ③ 底部：价格模块（当前票档单价 + 说明）
      _priceModule(t),
    ];
  }

  Widget _priceChip(int i) {
    final t = _priceTiers[i];
    final on = _priceTier == i;
    return PressableScale(
      onTap: () => setState(() => _priceTier = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: on ? AppColors.amberGradient : null,
            color: on ? null : AppColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
                color: on ? Colors.transparent : AppColors.cardBorder)),
        child: Text('¥${t[0]}',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: on ? AppColors.amberInk : AppColors.textPrimary)),
      ),
    );
  }

  Widget _priceModule(List t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3DE5477B))),
          child: Row(children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t[1] as String,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  RichText(
                      text: TextSpan(
                          text: '¥${t[0]}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amber),
                          children: const [
                        TextSpan(
                            text: ' /张',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary))
                      ])),
                ]),
            const Spacer(),
            AmberButton('确认选座',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PackageBuilderScreen())),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 13)),
          ]),
        ),
      );

  // ── 选门票(套餐第一步)：只呈现差异，不裸露单票价(只打包卖) ──
  List<Widget> _ticketTiers() {
    // [档位, 余票, 卖点]
    final tiers = [
      ['内场企位', 8, '最佳视野 · 距舞台最近'],
      ['A区看台', 4, '正面看台 · 视野开阔'],
      ['B区看台', 30, '高性价比之选'],
    ];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Text('选择票档 · 查看对应看台位置与实时价格',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ),
      ...tiers.map((t) =>
          _tierRow(t[0] as String, t[1] as int, t[2] as String)),
    ];
  }

  int _pickedTier = -1;

  Widget _tierRow(String tier, int left, String note) {
    final idx = ['内场企位', 'A区看台', 'B区看台'].indexOf(tier);
    final on = _pickedTier == idx;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: PressableScale(
        onTap: () => setState(() => _pickedTier = on ? -1 : idx),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: on ? const Color(0x1FE5477B) : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: on ? const Color(0x99E5477B) : AppColors.cardBorder,
                  width: on ? 1.5 : 1)),
          child: Row(children: [
            Icon(on ? LucideIcons.checkCircle2 : LucideIcons.circle,
                size: 18, color: on ? AppColors.amber : AppColors.textFaint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(tier,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      if (left <= 6) ...[
                        const SizedBox(width: 8),
                        _MiniUrgency(left),
                      ],
                    ]),
                    const SizedBox(height: 6),
                    Text(note,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ]),
            ),
            const SizedBox(width: 12),
            Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textFaint),
          ]),
        ),
      ),
    );
  }

  // ── 担保规则 / 退改 / 赔付 (支付前展示 PRD 硬规则) ──
  Widget _guaranteeBlock() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3DE5477B))),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(LucideIcons.shieldCheck,
                      size: 18, color: AppColors.amber),
                  SizedBox(width: 8),
                  Text('穩飛保障',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                _guardLine('担保出票', '承诺场次在最迟出票时间前交付；逾期补同档/免费升档/全额退款'),
                _guardLine('验票保真', '每张票核验来源与票权后交付，杜绝假票/重复二维码'),
                _guardLine('现场兜底', '现场无法入场即时上报，客服最高优先级补票；仍无法入场按 ¥500/票（单笔上限 ¥2,000）赔付'),
              ]),
        ),
      );

  Widget _guardLine(String title, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(LucideIcons.check, size: 13, color: AppColors.amber),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
                text: TextSpan(
                    text: '$title  ',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    children: [
                  TextSpan(
                      text: desc,
                      style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary))
                ])),
          ),
        ]),
      );

  // ── sticky 底栏 ──
  Widget _stickyBar() => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Glass(
          radius: BorderRadius.zero,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: Row(children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('门票起价',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textTertiary)),
                  RichText(
                      text: TextSpan(
                          text: '¥1,680',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amber),
                          children: const [
                        TextSpan(
                            text: ' 起',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary))
                      ])),
                ]),
            const Spacer(),
            AmberButton('立即抢票',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PackageBuilderScreen())),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14)),
          ]),
        ),
      );
}

/// 稀缺标（仅剩 N 张）——票档余票紧张时提示，不暴露现票/担保
class _MiniUrgency extends StatelessWidget {
  final int left;
  const _MiniUrgency(this.left);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: const Color(0x29FF785A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x66FF785A))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(LucideIcons.flame, size: 11, color: AppColors.deal),
        const SizedBox(width: 3),
        Text('仅剩 $left 张',
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.deal)),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textTertiary),
      const SizedBox(width: 5),
      Text(text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
