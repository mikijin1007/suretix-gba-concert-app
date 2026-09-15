import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'agreement_screen.dart';
import 'auth_screen.dart';
import 'account_security_screen.dart';
import 'phone_bind_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

/// 设置 —— 账号/通知/隐私/缓存/关于/退出登录。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushOrder = true;
  bool _pushActivity = true;
  bool _pushNearby = false;
  double _cacheMb = 12.4; // 缓存大小(清理后归零)
  bool _clearing = false;

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  // 清除缓存：确认 → 清理中 → 归零
  Future<void> _clearCache() async {
    if (_clearing) return;
    if (_cacheMb == 0) {
      _toast('缓存已是最小，无需清理');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgElevate,
        title: const Text('清除缓存',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text(
            '将清理 ${_cacheMb.toStringAsFixed(1)} MB 图片与页面缓存。订单与登录信息不受影响。',
            style: const TextStyle(
                fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('取消',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('立即清理',
                  style: TextStyle(
                      color: AppColors.amber, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _clearing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _cacheMb = 0;
      _clearing = false;
    });
    _toast('缓存已清理');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('设置',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('账号 · 通知 · 隐私偏好',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
            ]),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          _group('账号', [
            _nav('账号与安全', LucideIcons.userCog,
                onTap: () =>
                    AppRoute.to(context, const AccountSecurityScreen())),
            _nav('绑定手机 138****1206', LucideIcons.smartphone,
                onTap: () => AppRoute.to(context, const PhoneBindScreen())),
          ]),
          _group('通知', [
            _toggle('订单与出票通知', _pushOrder, (v) => setState(() => _pushOrder = v)),
            _toggle('活动与优惠通知', _pushActivity, (v) => setState(() => _pushActivity = v)),
            _toggle('附近演出推荐', _pushNearby, (v) => setState(() => _pushNearby = v)),
          ]),
          _group('通用', [
            _nav(
                _clearing
                    ? '正在清理…'
                    : '清除缓存 · ${_cacheMb.toStringAsFixed(1)} MB',
                LucideIcons.trash2,
                onTap: _clearCache),
            _nav('隐私政策', LucideIcons.lock,
                onTap: () => AppRoute.to(context, const PrivacyScreen())),
            _nav('购票服务协议', LucideIcons.fileText,
                onTap: () => AppRoute.to(context, const AgreementScreen())),
            _nav('关于穩飛 · v1.0.0', LucideIcons.info,
                onTap: () => AppRoute.to(context, const AboutScreen())),
          ]),
          const SizedBox(height: 24),
          _logout(context),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary)),
              ),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Column(children: children),
              ),
            ]),
      );

  Widget _nav(String label, IconData icon, {VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 17, color: AppColors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: AppColors.textFaint),
          ]),
        ),
      );

  Widget _toggle(String label, bool val, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: val,
            onChanged: onChanged,
            activeColor: AppColors.amberInk,
            activeTrackColor: AppColors.amber,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.card,
          ),
        ]),
      );

  Widget _logout(BuildContext context) => PressableScale(
        onTap: () => _confirmLogout(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x55FF4D4D))),
          child: const Text('退出登录',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6B6B))),
        ),
      );

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('退出登录',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: const Text('确定要退出当前账号吗?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (r) => false),
            child: const Text('退出', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}
