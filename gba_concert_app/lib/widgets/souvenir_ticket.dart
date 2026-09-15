import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// 电子纪念票（大麦样式）—— 浅色卡 + 竖版海报 + 全息 VIP 印章 + 齿孔撕线 + 限量编号。
class SouvenirTicket extends StatelessWidget {
  final String show;
  final String dateLine; // 2026-08-29 20:00 | 启德体育园主场馆
  final String qtyPrice; // 2张票 ¥6,560.00
  final String owner; // @NIKKI_JIN
  final String serial; // 049029
  final int posterSeed;

  const SouvenirTicket({
    super.key,
    required this.show,
    required this.dateLine,
    required this.qtyPrice,
    this.owner = '@NIKKI_JIN',
    this.serial = '049029',
    this.posterSeed = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── 上半：海报 + 演出信息 ──
      Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F1EC), // 纸感浅色
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(children: [
          // 竖版海报
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: PosterBox(seed: posterSeed),
            ),
          ),
          const SizedBox(height: 14),
          // 演出名 + 两侧全息印章
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _holoStamp(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(show,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16161A))),
                    const SizedBox(height: 8),
                    Text(dateLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF5A5A62))),
                    const SizedBox(height: 4),
                    Text(qtyPrice,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5A5A62))),
                  ]),
            ),
            const SizedBox(width: 8),
            _holoStamp(),
          ]),
        ]),
      ),
      // ── 中间齿孔撕线 ──
      const _PerforationLine(),
      // ── 下半：归属 + 限量编号 ──
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F1EC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Column(children: [
          // 缩略图 + 担保出票文案 + 二维码
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 54,
                height: 54,
                child: PosterBox(seed: posterSeed),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('穩飛担保出票 · 实体票已上传',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16161A))),
                    SizedBox(height: 5),
                    Text('扫码一起来看现场',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF5A5A62))),
                  ]),
            ),
            const SizedBox(width: 10),
            // 二维码
            Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: const _QrMark(),
            ),
          ]),
          const SizedBox(height: 14),
          // 底部齿孔
          const _NotchRow(),
        ]),
      ),
    ]);
  }

  // 全息 VIP 印章
  Widget _holoStamp() => Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8E6F0),
              Color(0xFFE8D4F2),
              Color(0xFFFAE3C8),
              Color(0xFFC9E9D8),
            ],
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Text('穩飛',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3A3A44))),
          Text('VIP',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Color(0xFF3A3A44))),
        ]),
      );

}

/// 简化二维码图案(装饰用,三个定位角 + 随机点阵)
class _QrMark extends StatelessWidget {
  const _QrMark();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _QrPainter(), size: Size.infinite);
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF16161A);
    const n = 7; // 7x7 网格
    final cell = size.width / n;

    // 固定图案：1=实心
    const grid = [
      [1, 1, 1, 0, 1, 1, 1],
      [1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 0, 1, 1, 1],
      [0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 0, 1, 1],
      [1, 1, 1, 0, 1, 1, 0],
    ];
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (grid[y][x] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  x * cell + cell * 0.1,
                  y * cell + cell * 0.1,
                  cell * 0.8,
                  cell * 0.8),
              Radius.circular(cell * 0.2),
            ),
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 齿孔撕线(两侧半圆缺口 + 中间虚线)
class _PerforationLine extends StatelessWidget {
  const _PerforationLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(children: [
        _halfCircle(true),
        Expanded(
          child: Center(
            child: LayoutBuilder(builder: (_, box) {
              final n = (box.maxWidth / 9).floor().clamp(6, 40);
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      n,
                      (_) => Container(
                            width: 4,
                            height: 2,
                            color: const Color(0xFFBFBEB8),
                          )));
            }),
          ),
        ),
        _halfCircle(false),
      ]),
    );
  }

  Widget _halfCircle(bool left) => Container(
        width: 9,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.horizontal(
            left: left ? Radius.zero : const Radius.circular(9),
            right: left ? const Radius.circular(9) : Radius.zero,
          ),
        ),
      );
}

/// 卡片底部齿孔
class _NotchRow extends StatelessWidget {
  const _NotchRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: LayoutBuilder(builder: (_, box) {
        final n = (box.maxWidth / 16).floor().clamp(6, 30);
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                n,
                (_) => Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.bg, shape: BoxShape.circle),
                    )));
      }),
    );
  }
}
