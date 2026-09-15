import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth_flow_screen.dart';

void main() => runApp(const GbaApp());

/// 桌面/Web 预览时把内容约束成手机宽度，居中；真机全宽自然铺满。
class _PhoneShell extends StatelessWidget {
  final Widget child;
  const _PhoneShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width <= 480) return _withStatusBar(child); // 真机/窄窗：直接全宽

    // 桌面/Web：固定手机逻辑尺寸(390x844)，整体等比缩放适配视口高度，居中留边。
    // 用 FittedBox 缩放真实渲染的手机画面(而非谎报 MediaQuery)，任何页面都不溢出。
    const baseW = 390.0, baseH = 844.0;
    return ColoredBox(
      color: const Color(0xFF0C0C0E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AspectRatio(
            aspectRatio: baseW / baseH,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: SizedBox(
                  width: baseW,
                  height: baseH,
                  child: _withStatusBar(child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 状态栏已移除，直接返回内容
  Widget _withStatusBar(Widget content) => content;
}

class GbaApp extends StatelessWidget {
  const GbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '湾区看演',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // builder 包裹所有路由(含 Navigator.push 的新页面)，确保每页都在手机 shell 内
      builder: (context, child) => _PhoneShell(child: child ?? const SizedBox()),
      home: const AuthFlowScreen(),
    );
  }
}
