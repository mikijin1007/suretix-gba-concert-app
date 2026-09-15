import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';
import 'hotel_detail_screen.dart';
import 'seat_select_screen.dart';

/// 套餐组装器 —— 只打包卖，实时算价
/// 步骤：① 选门票档位 → ② 选酒店+房型 → ③ 加减住几晚(连住优惠) → 底部实时总价
class PackageBuilderScreen extends StatefulWidget {
  const PackageBuilderScreen({super.key});

  @override
  State<PackageBuilderScreen> createState() => _PackageBuilderScreenState();
}

class _PackageBuilderScreenState extends State<PackageBuilderScreen> {
  // 门票档位 [名, 单价, 卖点]
  static const _tiers = [
    ['内场企位', 3280, '最佳视野 · 距舞台最近'],
    ['A区看台', 2180, '正面看台 · 视野开阔'],
    ['B区看台', 1680, '高性价比之选'],
  ];
  // 酒店 [名, 升级房型, 每晚价, 距场馆, 星级, 图seed, 设施列表]
  static const _hotels = [
    ['尖沙咀凯悦', '豪华海景房', 1280, '距场馆 15 分钟', 5, 1,
      ['维港海景', '含双早', '室内泳池', '健身房']],
    ['红磡海景酒店', '海景双床房', 980, '步行 10 分钟直达', 4, 2,
      ['海景', '含双早', '近场馆', '24h前台']],
    ['旺角智选假日', '高级双床房', 680, '地铁 2 站', 4, 3,
      ['市景', '含双早', '近地铁', '免费WiFi']],
  ];

  int _step = 0; // 0=选票 1=选方案 2=附加
  int _session = 0; // 选中场次
  int _tier = 0;
  int _ticketQty = 2;
  int _hotel = 0;
  bool _hotelSelected = true; // 是否已选中酒店(可再次单击取消)
  int _checkIn = 29; // 入住日(8月N日)
  int _checkOut = 31; // 退房日
  bool _dateSelected = true; // 是否已选日期(再次单击入住日可取消)
  bool _addTransport = false;

  // ── 合规捆绑：门票必须 + (酒店套餐 或 观演礼包) 二选一 ──
  int _bundleMode = 0; // 0=酒店套餐(默认推荐·利润高) 1=观演礼包(不需住宿的合规出口)
  int _giftTier = 0; // 选中的礼包档
  bool _giftSelected = true; // 是否已选中礼包(可再次单击取消)
  // 观演礼包 [名, 价, 权益面值加总, 卖点, 权益列表]
  static const _giftPacks = [
    [
      '观演礼包 · 基础',
      199,
      800,
      '只看演出、不需住宿的超值之选',
      ['酒店自助早餐券 × 2', '场馆周边餐厅 8 折券', '下次购票立减 ¥200 券', '官方应援物料 9 折券']
    ],
    [
      '观演礼包 · 尊享',
      399,
      1600,
      '权益更足 · 送人自用都体面',
      ['五星酒店双人下午茶券', '酒店自助早餐券 × 2', '餐厅 8 折券 × 2', '下次购票立减 ¥400 券', 'VIP 专属客服通道']
    ],
  ];
  int get _giftPrice => _giftPacks[_giftTier][1] as int;
  int get _giftValue => _giftPacks[_giftTier][2] as int;
  // 每日房价系数(演出日周边溢价)：key=日期, value=溢价倍数
  static const _dayRate = {
    28: 1.0, 29: 1.6, 30: 1.6, 31: 1.3, 1: 1.0, 2: 1.0,
  };
  final Set<int> _addons = {}; // 升级服务加购
  static const _addonList = [
    ['专属应援物料包', '灯牌+手幅+荧光棒', 128],
    ['VIP 快速通道', '免排队优先入场', 200],
    ['演出纪念周边', '官方限定周边礼盒', 168],
  ];
  int get _addonTotal =>
      _addons.fold(0, (s, i) => s + (_addonList[i][2] as int));
  int _ticketMode = 0; // 0=按票档(系统分配·尽量连座) 1=按座位(自选)
  final Set<String> _pickedSeats = {}; // 按座位选中的具体座 "排-座"
  String _seatLabelStr = ''; // 自选座位文字(从选座页带回)
  int _seatUnitPrice = 0; // 自选座位单价(从选座页带回)
  int? _zoomZone; // 按座位：当前放大的分区(null=看全景分区图)
  int? _priceFilter; // 价位筛选(点图例价格键,null=显示全部) — ATG/Seatsio 模式
  final _tierPage = PageController(viewportFraction: 0.82);
  int _tierViewIdx = 0; // 票档视角图当前档

  @override
  void dispose() {
    _tierPage.dispose();
    super.dispose();
  }
  static const _transportPerPax = 260; // 高铁往返/人

  // ── 实时算价 ──
  // 按票档=数量×档价；按座位=选中座位数×档价(用内场档价示意)
  // 统一按观影人数计价(票品单价 × 人数)
  int get _effectiveQty => _ticketQty;
  // 按票档=数量×档价；按座位=选中座位数×座位单价(带回的单价)
  int get _ticketUnitPrice =>
      _ticketMode == 1 && _seatUnitPrice > 0
          ? _seatUnitPrice
          : (_tiers[_tier][1] as int);
  int get _ticketTotal => _ticketUnitPrice * _effectiveQty;
  int get _hotelPerNight => _hotels[_hotel][2] as int; // 基准房价
  int get _nights => (_checkOut - _checkIn).clamp(1, 6);

  // 每晚房价 = 基准价 × 当日系数(演出日溢价)；退房日不计
  int _rateOfDay(int day) =>
      (_hotelPerNight * (_dayRate[day] ?? 1.0)).round();

  int get _hotelTotal {
    if (!_dateSelected) return 0; // 未选日期不计房费
    var sum = 0;
    for (var d = _checkIn; d < _checkOut; d++) {
      sum += _rateOfDay(d);
    }
    return sum;
  }

  // 省心账：对比按最高单日价×晚数
  int get _hotelSaved {
    final maxRate = _rateOfDay(29); // 演出日峰值
    final base = maxRate * _nights;
    return (base - _hotelTotal).clamp(0, 99999);
  }
  int get _transportTotal =>
      _addTransport ? _transportPerPax * _effectiveQty : 0;
  // 捆绑物金额：酒店模式=房费；礼包模式=礼包价
  int get _bundleTotal => _bundleMode == 0
      ? (_hotelSelected ? _hotelTotal : 0)
      : (_giftSelected ? _giftPrice : 0);
  int get _total =>
      _ticketTotal + _bundleTotal + _transportTotal + _addonTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('定制观演套餐',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            children: [
              if (_step == 0) ..._stepTicket(),
              if (_step == 1) ..._stepHotel(),
              if (_step == 2) ..._stepConfirm(),
            ],
          ),
        ),
        // 选票步骤：底部固定悬浮「去选择票品」按钮
        if (_step == 0)
          Glass(
            radius: BorderRadius.zero,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
            child: _tierPriceModule(),
          ),
        // 酒店/附加步骤显示底部导航栏
        if (_step > 0) _bottomBar(),
      ]),
    );
  }

  // ── 顶部进度条：① 选票 ② 选酒店 ③ 确认 ──
  static const _steps = ['选票', '选方案', '附加'];
  Widget _progressBar() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        child: Row(
            children: List.generate(_steps.length * 2 - 1, (k) {
          if (k.isOdd) {
            // 连线
            final done = (k ~/ 2) < _step;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: done ? AppColors.amber : AppColors.cardBorder,
              ),
            );
          }
          final i = k ~/ 2;
          final done = i < _step;
          final active = i == _step;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: (done || active) ? AppColors.amberGradient : null,
                  color: (done || active) ? null : AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: (done || active)
                          ? Colors.transparent
                          : AppColors.cardBorder)),
              child: done
                  ? const Icon(LucideIcons.check,
                      size: 14, color: AppColors.amberInk)
                  : Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? AppColors.amberInk
                              : AppColors.textTertiary)),
            ),
            const SizedBox(height: 4),
            Text(_steps[i],
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.amber : AppColors.textTertiary)),
          ]);
        })),
      );

  // ── 步骤1：选票(大麦版式：顶部票档价格 → 中间位置图 → 底部价格) ──
  List<Widget> _stepTicket() => [
        _sessionPicker(),
        _stepLabel('1', '选门票', '选票档 · 看位置 · 确认价格'),
        // ① 顶部横向票档价格胶囊
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: _tiers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _tierPriceChip(i),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(children: [
            Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.green, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${_tiers[_tier][0]} · ${_tiers[_tier][2]}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 14),
        // ② 中间：场馆位置示意图
        ..._venueOverview(),
        const SizedBox(height: 8),
      ];

  // 顶部票档价格胶囊
  Widget _tierPriceChip(int i) {
    final t = _tiers[i];
    final on = _tier == i;
    return PressableScale(
      onTap: () => setState(() {
        _tier = i;
        _tierViewIdx = i;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: on ? AppColors.amberGradient : null,
            color: on ? null : AppColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
                color: on ? Colors.transparent : AppColors.cardBorder)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${t[0]} ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: on
                      ? const Color(0xCC1A1200)
                      : AppColors.textSecondary)),
          Text('¥${t[1]}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: on ? AppColors.amberInk : AppColors.textPrimary)),
        ]),
      ),
    );
  }

  // 底部：一个「去选择票品」按钮 → 进入该区域的票品列表页
  Widget _tierPriceModule() {
    final t = _tiers[_tier];
    final basePrice = t[1] as int;
    return PressableScale(
        onTap: () => _openTicketList(t[0] as String, basePrice),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
              gradient: AppColors.amberGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x4DE5477B),
                    blurRadius: 20,
                    offset: Offset(0, 8))
              ]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(LucideIcons.ticket, size: 18, color: AppColors.amberInk),
            SizedBox(width: 8),
            Text('去选择票品',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amberInk)),
          ]),
        ),
    );
  }

  // 打开票品列表页，选定后进入酒店推荐步骤
  Future<void> _openTicketList(String areaName, int basePrice) async {
    setState(() => _ticketMode = 1);
    final result = await AppRoute.to<SeatPick>(
      context,
      SeatSelectScreen(
        show: '周杰伦 嘉年华巡演',
        session:
            '2026/${_sessions[_session][0]} ${_sessions[_session][1]} · ${_sessions[_session][2]}',
        venue: '香港 · 启德体育园主场馆',
        areaName: areaName,
        unitPrice: basePrice,
      ),
    );
    if (result == null) return; // 用户返回未选票
    setState(() {
      _pickedSeats
        ..clear()
        ..addAll(result.seats);
      _seatLabelStr = result.seatLabel;
      _seatUnitPrice = result.unitPrice;
      _step = 1; // 选好票品 → 进入酒店推荐步骤
    });
  }

  Widget _ticketProductRow({
    required Color dotColor,
    required String title,
    required String sub,
    required String note,
    required int price,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(children: [
            // 左侧色条
            Container(width: 4, color: dotColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(sub,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(note,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textFaint)),
                        ]),
                  ),
                  const SizedBox(width: 10),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: '¥$price',
                                style: const TextStyle(
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
                        const SizedBox(height: 8),
                        PressableScale(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                                gradient: AppColors.amberGradient,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('购买',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amberInk)),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 步骤2：选酒店(酒店+住几晚+交通) ──
  List<Widget> _stepHotel() => [
        const SizedBox(height: 8),
        _bundleTabs(),
        if (_bundleMode == 0) ...[
          // 先选入住日期，再挑酒店
          _stepLabel('日', '选择入住日期', '不同日期房价不同 · 演出日周边溢价'),
          _datePicker(),
          ..._hotelCards(),
        ] else ...[
          _giftIntro(),
          ..._giftCards(),
        ],
      ];

  // ── 合规捆绑二选一切换 ──
  Widget _bundleTabs() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            _bundleTab('酒店套餐', '住宿+双早 · 推荐', LucideIcons.bedDouble, 0),
            _bundleTab('观演礼包', '不需住宿？选它', LucideIcons.gift, 1),
          ]),
        ),
      );

  Widget _bundleTab(String label, String sub, IconData icon, int idx) {
    final on = _bundleMode == idx;
    return Expanded(
      child: PressableScale(
        onTap: () => setState(() => _bundleMode = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
              gradient: on ? AppColors.amberGradient : null,
              borderRadius: BorderRadius.circular(11)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 14,
                  color: on ? AppColors.amberInk : AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          on ? AppColors.amberInk : AppColors.textSecondary)),
            ]),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    fontSize: 9,
                    color: on
                        ? const Color(0xCC1A1200)
                        : AppColors.textFaint)),
          ]),
        ),
      ),
    );
  }

  // 礼包说明条(弱化"必须买",突出权益面值)
  Widget _giftIntro() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0x1FE5477B), Color(0x08E5477B)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x3DE5477B))),
          child: Row(children: const [
            Icon(LucideIcons.sparkles, size: 16, color: AppColors.amber),
            SizedBox(width: 10),
            Expanded(
              child: Text('只看演出、不需要住宿？选观演礼包即可 — 含餐饮、购票等多重权益，多张券叠加超值。',
                  style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: AppColors.textSecondary)),
            ),
          ]),
        ),
      );

  // 礼包卡片(2档，突出权益面值加总)
  List<Widget> _giftCards() => List.generate(_giftPacks.length, (i) {
        final g = _giftPacks[i];
        final on = _giftSelected && _giftTier == i;
        final perks = g[4] as List;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          child: PressableScale(
            onTap: () => setState(() {
              if (_giftSelected && _giftTier == i) {
                _giftSelected = false; // 再次单击取消
              } else {
                _giftTier = i;
                _giftSelected = true;
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: on ? const Color(0x99E5477B) : AppColors.cardBorder,
                      width: on ? 1.5 : 1)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: on ? AppColors.amberGradient : null,
                            border: Border.all(
                                color: on
                                    ? Colors.transparent
                                    : AppColors.cardBorder,
                                width: 1.5)),
                        child: on
                            ? const Icon(LucideIcons.check,
                                size: 12, color: AppColors.amberInk)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(g[0] as String,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0x1F4EC38A),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('含¥${g[2]}权益',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(g[3] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ),
                    const SizedBox(height: 12),
                    ...perks.map((p) => Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 7),
                          child: Row(children: [
                            const Icon(LucideIcons.ticket,
                                size: 12, color: AppColors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(p as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ),
                          ]),
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: AppColors.line, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 6),
                      child: Row(children: [
                        RichText(
                            text: TextSpan(
                                text: '礼包价 ',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary),
                                children: [
                              TextSpan(
                                  text: '¥${g[1]}',
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.amber)),
                            ])),
                        const Spacer(),
                        Text('权益价值 ¥${g[2]}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textFaint,
                                decoration: TextDecoration.lineThrough)),
                      ]),
                    ),
                  ]),
            ),
          ),
        );
      });

  // ── 步骤3：附加项(可选加购) + 套餐预览 ──
  List<Widget> _stepConfirm() => [
        _stepLabel('+', '跨境交通', '专车接驳 · 免排队过关(可选)'),
        _transportCard(),
        _stepLabel('★', '升级服务', '让观演更省心(可选)'),
        ..._extraAddons(),
        _stepLabel('=', '套餐预览', '核对后去支付确认'),
        _priceBreakdown(),
      ];

  // ── 选场次：日期 + 时间胶囊(照参考图) ──
  static const _sessions = [
    ['08/29', '周五', '20:00'],
    ['08/30', '周六', '20:00'],
    ['08/31', '周日', '19:30'],
  ];
  Widget _sessionPicker() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('选择场次',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
              children: List.generate(_sessions.length, (i) {
            final on = _session == i;
            final s = _sessions[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PressableScale(
                onTap: () => setState(() => _session = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      gradient: on ? AppColors.amberGradient : null,
                      color: on ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: on
                              ? Colors.transparent
                              : AppColors.cardBorder)),
                  child: Column(children: [
                    Text(s[0],
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color:
                                on ? AppColors.amberInk : AppColors.textPrimary)),
                    Text('${s[1]} ${s[2]}',
                        style: TextStyle(
                            fontSize: 9,
                            color: on
                                ? const Color(0xCC1A1200)
                                : AppColors.textTertiary)),
                  ]),
                ),
              ),
            );
          })),
          const SizedBox(height: 16),
          _paxPicker(),
          const SizedBox(height: 14),
        ]),
      );

  // 观影人数选择(1–6 人)
  Widget _paxPicker() => Row(children: [
        const Text('观影人数',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const Spacer(),
        _paxStep(LucideIcons.minus, _ticketQty > 1, () {
          setState(() => _ticketQty--);
        }),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text('$_ticketQty',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ),
        _paxStep(LucideIcons.plus, _ticketQty < 6, () {
          setState(() => _ticketQty++);
        }),
      ]);

  Widget _paxStep(IconData icon, bool enabled, VoidCallback onTap) =>
      Opacity(
        opacity: enabled ? 1 : 0.35,
        child: PressableScale(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder)),
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),
        ),
      );

  Widget _showBanner() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 90,
            child: Stack(fit: StackFit.expand, children: [
              const PosterBox(seed: 0),
              DecoratedBox(decoration: BoxDecoration(gradient: AppColors.scrim())),
              Positioned(
                left: 14,
                bottom: 10,
                child: Row(children: [
                  Text('周杰伦 嘉年华巡演',
                      style: AppTheme.displaySerif(size: 18)),
                ]),
              ),
              const Positioned(
                right: 12,
                top: 12,
                child: _TrustPill(),
              ),
            ]),
          ),
        ),
      );

  Widget _stepLabel(String no, String title, String sub) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
        child: Row(children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary)),
          ),
        ]),
      );

  // ── 选门票双模式切换 ──
  Widget _ticketModeTabs() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            _modeTab('按票档', '省心 · 系统尽量连座', LucideIcons.listChecks, 0),
            _modeTab('按座位', '自选位置 · 看视角', LucideIcons.armchair, 1),
          ]),
        ),
      );

  Widget _modeTab(String label, String sub, IconData icon, int idx) {
    final on = _ticketMode == idx;
    return Expanded(
      child: PressableScale(
        onTap: () => setState(() => _ticketMode = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
              gradient: on ? AppColors.amberGradient : null,
              borderRadius: BorderRadius.circular(11)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 14,
                  color: on ? AppColors.amberInk : AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          on ? AppColors.amberInk : AppColors.textSecondary)),
            ]),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    fontSize: 9,
                    color: on
                        ? const Color(0xCC1A1200)
                        : AppColors.textFaint)),
          ]),
        ),
      ),
    );
  }

  // ── 按座位模式(照 Tyler)：全景分区图 → 点区放大 → 座位号网格 ──
  // 分区 [名, 最低价, 视角图view, 状态(0可选/1紧张/2售罄)]
  static const _seatZones = [
    ['内场企位', 3280, 1, 1],
    ['A区 正面', 2180, 2, 0],
    ['B区 正面', 1680, 3, 0],
    ['C区 侧面', 1280, 4, 2],
  ];

  List<Widget> _seatMode() {
    if (_zoomZone == null) return _venueOverview();
    return _zoomedZone(_zoomZone!);
  }

  // 全景分区图：俯视场馆，各区显示最低价，点区放大
  List<Widget> _venueOverview() => [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: Row(children: const [
            Icon(LucideIcons.info, size: 13, color: AppColors.amber),
            SizedBox(width: 6),
            Expanded(
              child: Text('场馆座位分布示意图 · 具体座位以出票为准',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/seatmap.jpg',
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder)),
                child: const Text('座位图加载失败',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ),
            ),
          ),
        ),
      ];

  // 可点击价位键:点某价位只高亮该价位分区,其余变暗
  Widget _priceFilterBar() {
    // 去重价位,升序
    final prices = _seatZones
        .map((z) => z[1] as int)
        .toSet()
        .toList()
      ..sort();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _priceChip(null, '全部价位'),
          ...prices.map((p) => _priceChip(p, '¥$p')),
        ],
      ),
    );
  }

  Widget _priceChip(int? price, String label) {
    final on = _priceFilter == price;
    return PressableScale(
      onTap: () => setState(() => _priceFilter = on ? null : price),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
            gradient: on ? AppColors.amberGradient : null,
            color: on ? null : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: on ? Colors.transparent : AppColors.cardBorder)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: on ? AppColors.amberInk : AppColors.textSecondary)),
      ),
    );
  }

  Widget _zoneBlock(int zi, {bool fullWidth = false}) {
    final z = _seatZones[zi];
    final status = z[3] as int;
    final soldout = status == 2;
    final tight = status == 1;
    final base = soldout
        ? AppColors.textFaint
        : (tight ? AppColors.deal : const Color(0xFF4EC38A));
    // 价位筛选:选了价位且本区不匹配 → 变暗(ATG/Seatsio 模式)
    final dimmed = _priceFilter != null && z[1] != _priceFilter;
    return Opacity(
      opacity: dimmed ? 0.3 : 1,
      child: PressableScale(
        onTap: soldout ? null : () => setState(() => _zoomZone = zi),
        child: Container(
          height: fullWidth ? 52 : 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: soldout
                  ? const Color(0xFF1E1E20)
                  : base.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: base.withValues(alpha: 0.6))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(z[0] as String,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: base)),
            const SizedBox(height: 2),
            Text(soldout ? '已售罄' : '¥${z[1]} 起',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: soldout ? AppColors.textFaint : base)),
          ]),
        ),
      ),
    );
  }

  // 放大到某区：视角图 + 座位号网格
  List<Widget> _zoomedZone(int zi) {
    final z = _seatZones[zi];
    const rows = 6, cols = 11;
    final sold = {'2-4', '3-8', '4-6', '4-7', '5-2'};
    return [
      // 返回全景 + 区名 + 价
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
        child: Row(children: [
          PressableScale(
            onTap: () => setState(() => _zoomZone = null),
            child: Row(children: const [
              Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.amber),
              Text('全景',
                  style: TextStyle(fontSize: 12, color: AppColors.amber)),
            ]),
          ),
          const Spacer(),
          Text('${z[0]} · ¥${z[1]} 起',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
      ),
      // 视角图
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 130,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/view_${z[2]}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.card)),
              DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.scrim())),
              Positioned(
                left: 12,
                bottom: 10,
                child: Row(children: [
                  const Icon(LucideIcons.eye, size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                  Text('${z[0]} · 此位置视角参考',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ]),
              ),
            ]),
          ),
        ),
      ),
      // 座位号网格
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            const Text('↑ 靠近舞台',
                style: TextStyle(fontSize: 9, color: AppColors.amber)),
            const SizedBox(height: 10),
            for (int r = 1; r <= rows; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(
                      width: 20,
                      child: Text('$r排',
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
            const SizedBox(height: 6),
            _seatLegendRow(),
          ]),
        ),
      ),
      if (_pickedSeats.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0x1FE5477B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x3DE5477B))),
            child: Text('已选 ${_pickedSeats.length} 座 · ${_seatLabel()}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amberSoft)),
          ),
        ),
    ];
  }

  Widget _seatLegendRow() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _legendDot(const Color(0xFF4EC38A), '可选'),
        const SizedBox(width: 14),
        _legendDot(AppColors.amber, '已选'),
        const SizedBox(width: 14),
        _legendDot(AppColors.textFaint, '售出'),
      ]);

  Widget _legendDot(Color c, String t) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: c))),
        const SizedBox(width: 5),
        Text(t,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ]);

  String _seatLabel() {
    final s = _pickedSeats.toList()..sort();
    return s.map((e) {
      final p = e.split('-');
      return '${p[0]}排${p[1]}座';
    }).join('、');
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
        width: 21,
        height: 21,
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

  // ── ① 门票档位 · 票根横滑卡（参考图票根隐喻）──
  static const _tierView = [1, 2, 3]; // 各档视角图 view_N
  Widget _tierCarousel() => Column(children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _tierPage,
            itemCount: _tiers.length,
            onPageChanged: (i) => setState(() {
              _tier = i;
              _tierViewIdx = i;
            }),
            itemBuilder: (_, i) => _ticketStub(i),
          ),
        ),
        const SizedBox(height: 12),
        // 指示点
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_tiers.length, (i) {
              final on = i == _tier;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: on ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                    color: on ? AppColors.amber : const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(3)),
              );
            })),
        const SizedBox(height: 8),
      ]);

  Widget _ticketStub(int i) {
    final t = _tiers[i];
    final on = _tier == i;
    return AnimatedScale(
      scale: on ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: on ? const Color(0x99E5477B) : AppColors.cardBorder,
                width: on ? 1.5 : 1),
            boxShadow: on
                ? const [
                    BoxShadow(
                        color: Color(0x33E5477B),
                        blurRadius: 24,
                        offset: Offset(0, 8))
                  ]
                : null,
          ),
          child: Column(children: [
            // 票面上半：视角大图
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
              child: SizedBox(
                height: 178,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/view_${_tierView[i]}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.card)),
                  DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.scrim())),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0x99000000),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: const [
                        Icon(LucideIcons.eye, size: 11, color: Colors.white),
                        SizedBox(width: 4),
                        Text('此档视角',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ]),
                    ),
                  ),
                  if (on)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            shape: BoxShape.circle),
                        child: const Icon(LucideIcons.check,
                            size: 14, color: AppColors.amberInk),
                      ),
                    ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Text(t[0] as String,
                        style: AppTheme.displaySerif(size: 22)),
                  ),
                ]),
              ),
            ),
            // 齿孔撕线
            _perfLine(),
            // 票面下半：卖点 + 该档套餐起价
            Container(
              decoration: BoxDecoration(
                  color: on ? const Color(0x1FE5477B) : AppColors.card,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(19))),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t[2] as String,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        RichText(
                            text: TextSpan(
                                text: '${t[0]}套餐 ',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary),
                                children: [
                              TextSpan(
                                  text: '¥${t[1]}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.amber)),
                              const TextSpan(
                                  text: ' 起',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary)),
                            ])),
                      ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // 齿孔撕线（票根隐喻）
  Widget _perfLine() => SizedBox(
        height: 18,
        child: Stack(children: [
          Positioned(
            left: -9,
            top: 0,
            child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.bg, shape: BoxShape.circle)),
          ),
          Positioned(
            right: -9,
            top: 0,
            child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.bg, shape: BoxShape.circle)),
          ),
          Positioned.fill(
            left: 14,
            right: 14,
            top: 8,
            child: CustomPaint(painter: _DashPainter()),
          ),
        ]),
      );

  Widget _qtyStepper() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
        child: _stepperRow(
            icon: LucideIcons.ticket,
            label: '购买数量',
            sub: '多张优先连座',
            value: '$_ticketQty 张',
            onMinus: _ticketQty > 1
                ? () => setState(() => _ticketQty--)
                : null,
            onPlus: _ticketQty < 6
                ? () => setState(() => _ticketQty++)
                : null),
      );

  // ── ② 酒店 ──
  List<Widget> _hotelCards() => List.generate(_hotels.length, (i) {
        final h = _hotels[i];
        final on = _hotelSelected && _hotel == i;
        final star = h[4] as int;
        final amenities = h[6] as List;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: PressableScale(
            onTap: () => setState(() {
              if (_hotelSelected && _hotel == i) {
                _hotelSelected = false; // 再次单击取消
              } else {
                _hotel = i;
                _hotelSelected = true;
              }
            }),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: on
                          ? const Color(0x99E5477B)
                          : AppColors.cardBorder,
                      width: on ? 1.5 : 1),
                  boxShadow: on
                      ? const [
                          BoxShadow(
                              color: Color(0x33E5477B),
                              blurRadius: 20,
                              offset: Offset(0, 6))
                        ]
                      : null),
              child: Column(children: [
                // 酒店大图
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17)),
                  child: SizedBox(
                    height: 130,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/hotel_${h[5]}.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: AppColors.bgElevate)),
                      DecoratedBox(
                          decoration:
                              BoxDecoration(gradient: AppColors.scrim())),
                      // 房型升级+双早 福利标
                      Positioned(
                        top: 10,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              gradient: AppColors.amberGradient,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: const [
                            Icon(LucideIcons.arrowUp,
                                size: 10, color: AppColors.amberInk),
                            SizedBox(width: 3),
                            Text('房型升级 + 双早',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.amberInk)),
                          ]),
                        ),
                      ),
                      // 选中勾
                      if (on)
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                gradient: AppColors.amberGradient,
                                shape: BoxShape.circle),
                            child: const Icon(LucideIcons.check,
                                size: 14, color: AppColors.amberInk),
                          ),
                        ),
                      // 名称 + 星级
                      Positioned(
                        left: 14,
                        bottom: 10,
                        right: 14,
                        child: Row(children: [
                          Text(h[0] as String,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(width: 6),
                          Row(
                              children: List.generate(
                                  star,
                                  (_) => const Icon(LucideIcons.star,
                                      size: 10, color: AppColors.amber))),
                        ]),
                      ),
                    ]),
                  ),
                ),
                // 房型 + 设施 icon 行
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(LucideIcons.bedDouble,
                              size: 13, color: AppColors.amber),
                          const SizedBox(width: 6),
                          Text(h[1] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Icon(LucideIcons.mapPin,
                              size: 11, color: AppColors.textFaint),
                          const SizedBox(width: 2),
                          Text(h[3] as String,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textFaint)),
                        ]),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: amenities
                              .map((a) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppColors.bgElevate,
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Text(a as String,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        PressableScale(
                          onTap: () => AppRoute.to(
                              context, HotelDetailScreen(hotel: kHotels[i])),
                          child: Row(children: const [
                            Icon(LucideIcons.images,
                                size: 13, color: AppColors.amber),
                            SizedBox(width: 5),
                            Text('查看房型 / 设施 / 位置详情',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.amber)),
                            Icon(LucideIcons.chevronRight,
                                size: 13, color: AppColors.amber),
                          ]),
                        ),
                      ]),
                ),
              ]),
            ),
          ),
        );
      });

  // ── ③ 住几晚 ──
  // 选日期：横排日历(8/28–9/2)，点选入住→退房区间，每日显示房价
  static const _dateDays = [28, 29, 30, 31, 1, 2];
  static const _dateMonth = {28: '8月', 29: '8月', 30: '8月', 31: '8月', 1: '9月', 2: '9月'};

  Widget _datePicker() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Column(children: [
          // 日历行
          Row(
              children: _dateDays.map((d) {
            // 未选日期时全部不高亮
            final inRange = _dateSelected && d >= _checkIn && d < _checkOut;
            final isIn = _dateSelected && d == _checkIn;
            final isOut = _dateSelected && d == _checkOut;
            final rate = _rateOfDay(d);
            final peak = (_dayRate[d] ?? 1.0) > 1.2;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: PressableScale(
                  onTap: () => setState(() => _pickDate(d)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        gradient: (isIn || isOut)
                            ? AppColors.amberGradient
                            : null,
                        color: (isIn || isOut)
                            ? null
                            : (inRange
                                ? const Color(0x1FE5477B)
                                : AppColors.card),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: (isIn || isOut)
                                ? Colors.transparent
                                : AppColors.cardBorder)),
                    child: Column(children: [
                      Text('$d',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: (isIn || isOut)
                                  ? AppColors.amberInk
                                  : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('¥$rate',
                          style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: (isIn || isOut)
                                  ? const Color(0xCC1A1200)
                                  : (peak
                                      ? AppColors.deal
                                      : AppColors.textTertiary))),
                    ]),
                  ),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 10),
          // 入住/退房 + 晚数总结
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder)),
            child: _dateSelected
                ? Row(children: [
                    _dateBadge('入住', '${_dateMonth[_checkIn]}$_checkIn日'),
                    const Icon(LucideIcons.arrowRight,
                        size: 16, color: AppColors.textFaint),
                    _dateBadge('退房', '${_dateMonth[_checkOut]}$_checkOut日'),
                    const Spacer(),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('共 $_nights 晚',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          if (_hotelSaved > 0)
                            Text('较峰值省 ¥$_hotelSaved',
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.green)),
                        ]),
                  ])
                // 未选日期：给出引导，不显示无效的入住退房
                : Row(children: const [
                    Icon(LucideIcons.calendarPlus,
                        size: 15, color: AppColors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('未选入住日期 · 点上方日期开始选择',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                    ),
                  ]),
          ),
          const SizedBox(height: 8),
          Row(children: const [
            Icon(LucideIcons.info, size: 11, color: AppColors.textFaint),
            SizedBox(width: 5),
            Expanded(
              child: Text('演出日(8/29–30)房价上浮，错峰入住更划算',
                  style: TextStyle(fontSize: 10, color: AppColors.textFaint)),
            ),
          ]),
          // 与下方酒店卡片留出呼吸空间
          const SizedBox(height: 18),
        ]),
      );

  void _pickDate(int d) {
    // 未选状态：点任意日期重新开始选(该日入住，次日退房)
    if (!_dateSelected) {
      _dateSelected = true;
      _checkIn = d;
      _checkOut = d + 1;
      return;
    }
    // 已选状态下点入住日 → 取消整个日期选择
    if (d == _checkIn) {
      _dateSelected = false;
      return;
    }
    // 点选逻辑：先定入住，再定退房；已成区间则重置为新入住
    if (_checkOut - _checkIn >= 1 && d != _checkIn && d != _checkOut) {
      if (d < _checkIn) {
        _checkIn = d;
      } else {
        _checkOut = d;
      }
    } else if (d <= _checkIn) {
      _checkIn = d;
      if (_checkOut <= d) _checkOut = d + 1;
    } else {
      _checkOut = d;
    }
    if (_checkOut <= _checkIn) _checkOut = _checkIn + 1;
  }

  Widget _dateBadge(String label, String value) => Row(children: [
        Text('$label ',
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
      ]);

  Widget _stepperRow({
    required IconData icon,
    required String label,
    required String sub,
    required String value,
    VoidCallback? onMinus,
    VoidCallback? onPlus,
    bool highlight = false,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 11,
                          color: highlight
                              ? AppColors.green
                              : AppColors.textTertiary)),
                ]),
          ),
          _roundBtn(LucideIcons.minus, onMinus),
          SizedBox(
              width: 44,
              child: Text(value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800))),
          _roundBtn(LucideIcons.plus, onPlus),
        ]),
      );

  Widget _roundBtn(IconData icon, VoidCallback? onTap) => PressableScale(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: onTap == null
                  ? const Color(0xFF1E1E20)
                  : const Color(0x24E5477B),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                  color: onTap == null
                      ? const Color(0xFF2A2A2D)
                      : const Color(0x66E5477B))),
          child: Icon(icon,
              size: 15,
              color: onTap == null ? AppColors.textFaint : AppColors.amber),
        ),
      );

  // ── 可选加购交通 ──
  Widget _transportCard() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: PressableScale(
          onTap: () => setState(() => _addTransport = !_addTransport),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color:
                    _addTransport ? const Color(0x1FE5477B) : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _addTransport
                        ? const Color(0x99E5477B)
                        : AppColors.cardBorder,
                    width: _addTransport ? 1.5 : 1)),
            child: Row(children: [
              Icon(_addTransport ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  size: 18,
                  color:
                      _addTransport ? AppColors.amber : AppColors.textFaint),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('广深港高铁往返接送',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      SizedBox(height: 3),
                      Text('专车接驳 · 免排队过关',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ]),
              ),
              Text('+¥$_transportPerPax/人',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber)),
            ]),
          ),
        ),
      );

  // ── 升级服务可选加购 ──
  List<Widget> _extraAddons() => List.generate(_addonList.length, (i) {
        final a = _addonList[i];
        final on = _addons.contains(i);
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: PressableScale(
            onTap: () => setState(() {
              if (on) {
                _addons.remove(i);
              } else {
                _addons.add(i);
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: on ? const Color(0x1FE5477B) : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: on
                          ? const Color(0x99E5477B)
                          : AppColors.cardBorder,
                      width: on ? 1.5 : 1)),
              child: Row(children: [
                Icon(on ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    size: 18, color: on ? AppColors.amber : AppColors.textFaint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a[0] as String,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(a[1] as String,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textTertiary)),
                      ]),
                ),
                Text('+¥${a[2]}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber)),
              ]),
            ),
          ),
        );
      });

  // ── 价格明细 ──
  Widget _priceBreakdown() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            // 套餐一价全含，不拆门票/酒店单价(用户规则)
            if (_bundleMode == 0)
              _priceLine(
                  _hotelSelected
                      ? '${_tiers[_tier][0]}套餐 · ${_effectiveQty}人'
                      : '${_tiers[_tier][0]}门票 · ${_effectiveQty}人',
                  null,
                  sub: _hotelSelected
                      ? '含门票 + ${_hotels[_hotel][0]} $_nights 晚(房型升级+双早)'
                      : '仅门票 · 未选酒店套餐')
            else
              _priceLine(
                  _giftSelected
                      ? '${_tiers[_tier][0]} · ${_effectiveQty}人 + ${_giftPacks[_giftTier][0]}'
                      : '${_tiers[_tier][0]}门票 · ${_effectiveQty}人',
                  null,
                  sub: _giftSelected
                      ? '含门票 + 观演礼包(含¥$_giftValue权益)'
                      : '仅门票 · 未选观演礼包'),
            if (_bundleMode == 0 && _hotelSelected && _hotelSaved > 0)
              _priceLine('错峰省', -_hotelSaved, highlight: true),
            if (_addTransport)
              _priceLine('高铁接送 × $_effectiveQty', _transportTotal),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.line, height: 1),
            ),
            Row(children: [
              const Text('套餐合计',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('¥$_total',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber)),
            ]),
          ]),
        ),
      );

  Widget _priceLine(String label, int? amount,
          {bool highlight = false, String? sub}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: highlight
                              ? AppColors.green
                              : AppColors.textSecondary)),
                  if (sub != null) ...[
                    const SizedBox(height: 3),
                    Text(sub,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textFaint)),
                  ],
                ]),
          ),
          const SizedBox(width: 12),
          if (amount != null)
            Text(amount < 0 ? '-¥${-amount}' : '¥$amount',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        highlight ? AppColors.green : AppColors.textPrimary)),
        ]),
      );

  // 未选酒店/礼包时的建议购买套餐弹窗
  void _showBundleSuggestDialog() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: AppColors.bgElevate,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  gradient: AppColors.amberGradient, shape: BoxShape.circle),
              child: const Icon(LucideIcons.sparkles,
                  size: 26, color: AppColors.amberInk),
            ),
            const SizedBox(height: 16),
            const Text('建议购买套餐哦～',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'App 与多家酒店、餐厅都有合作，购买套餐可享房型升级、双早、周边餐饮折扣等专属权益，更划算也更省心。',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                child: PressableScale(
                  onTap: () {
                    Navigator.of(dialogCtx).pop();
                    setState(() => _step++); // 不用了 → 继续下一步
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: const Text('不用了',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressableScale(
                  onTap: () => Navigator.of(dialogCtx).pop(), // 去购买 → 留在选套餐
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x59C9962F),
                              blurRadius: 18,
                              offset: Offset(0, 8))
                        ]),
                    child: const Text('去购买',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberInk)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final last = _step == 2;
    return Glass(
      radius: BorderRadius.zero,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: Row(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(last ? '套餐合计' : '当前预估',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textTertiary)),
              Text('¥$_total',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber)),
            ]),
        const Spacer(),
        if (_step > 0)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PressableScale(
              onTap: () => setState(() => _step--),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder)),
                child: const Text('上一步',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
            ),
          ),
        // 方案步骤必须二选一：酒店(需选日期)/礼包都没选时禁用「下一步」
        Builder(builder: (_) {
          final bundleChosen = _bundleMode == 0
              ? (_hotelSelected && _dateSelected)
              : _giftSelected;
          final canNext = _step != 1 || bundleChosen;
          return Opacity(
            opacity: canNext ? 1 : 0.4,
            child: AmberButton(last ? '去支付' : '下一步',
                onTap: !canNext
                    ? null
                    : () {
                        if (!last) {
                          setState(() => _step++);
                        } else {
                          AppRoute.to(
                              context,
                              CheckoutScreen(
                          show: '周杰伦 嘉年华巡演',
                          session: '2026/08/${29 + _session} · ${_sessions[_session][2]}',
                          venue: '香港 · 启德体育园主场馆',
                          ticketDesc: _ticketMode == 0
                              ? '${_tiers[_tier][0]} × $_effectiveQty'
                              : '$_seatLabelStr × $_effectiveQty',
                          seatMode: _ticketMode == 1 && _pickedSeats.isNotEmpty,
                          hasBundle: _bundleMode == 0 ? _hotelSelected : _giftSelected,
                          bundleIsHotel: _bundleMode == 0,
                          hotel: _hotels[_hotel][0] as String,
                          hotelStar: _hotels[_hotel][4] as int,
                          room: '${_hotels[_hotel][1]}（升级）+ 双早',
                          nights: _nights,
                          giftName: _giftPacks[_giftTier][0] as String,
                          giftValue: _giftValue,
                          giftPerks: List<String>.from(
                              _giftPacks[_giftTier][4] as List),
                          transport: _addTransport,
                          total: _total,
                        ));
                        }
                      },
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 14)),
          );
        }),
      ]),
    );
  }
}

/// 信任标（统一）：品牌承诺「穩出票」
class _TrustPill extends StatelessWidget {
  const _TrustPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0x66000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x66E5477B))),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.amber),
        SizedBox(width: 4),
        Text('穩出票',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.amber)),
      ]),
    );
  }
}

/// 票根撕线虚线
class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.5;
    const dash = 5.0, gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
