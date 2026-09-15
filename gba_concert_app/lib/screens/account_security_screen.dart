import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 账号与安全 —— 登录密码、支付密码、实名认证、设备管理、注销账号。
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _bioLogin = true; // 指纹/面容登录
  bool _payVerify = true; // 支付需验证

  void _toast(String msg) =>
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
        title: const Text('账号与安全',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // 安全等级
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0x33E5477B), Color(0x0DE5477B)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x4DE5477B))),
            child: Row(children: [
              const Icon(LucideIcons.shieldCheck,
                  size: 30, color: AppColors.amber),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('账号安全等级:高',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('已完成手机绑定与实名认证,建议开启支付验证',
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.textSecondary)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          _group('登录与密码', [
            _nav('修改登录密码', LucideIcons.keyRound,
                sub: '上次修改 2026/06/12',
                onTap: () => _pwdSheet('修改登录密码')),
            _nav('设置支付密码', LucideIcons.wallet,
                sub: '已设置 · 6 位数字',
                onTap: () => _pwdSheet('修改支付密码')),
            _toggle('指纹 / 面容登录', _bioLogin, (v) {
              setState(() => _bioLogin = v);
              _toast(v ? '已开启生物识别登录' : '已关闭生物识别登录');
            }),
            _toggle('支付时需身份验证', _payVerify, (v) {
              setState(() => _payVerify = v);
              _toast(v ? '支付将需要验证' : '已关闭支付验证');
            }),
          ]),
          _group('实名信息', [
            _nav('实名认证', LucideIcons.badgeCheck,
                sub: '王小明 · 已认证',
                trailing: const Text('已认证',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green)),
                onTap: () => _toast('实名信息已认证,如需变更请联系客服')),
          ]),
          _group('登录设备', [
            _device('iPhone 15 Pro', '深圳 · 当前设备', true),
            _device('MacBook Pro', '深圳 · 2 小时前', false),
            _device('iPad Air', '广州 · 3 天前', false),
          ]),
          const SizedBox(height: 20),
          PressableScale(
            onTap: _confirmDeactivate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x55FF4D4D))),
              child: const Text('注销账号',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B6B))),
            ),
          ),
          const SizedBox(height: 12),
          const Text('注销后账号数据将无法恢复,未使用的券与余额将失效。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
        ],
      ),
    );
  }

  // 修改密码弹窗
  void _pwdSheet(String title) {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.bgElevate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            _field(oldC, '当前密码', obscure: true),
            const SizedBox(height: 12),
            _field(newC, '新密码(8-20 位,含字母与数字)', obscure: true),
            const SizedBox(height: 12),
            _field(confirmC, '确认新密码', obscure: true),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: PressableScale(
                  onTap: () => Navigator.of(sheetCtx).pop(),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: const Text('取消',
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
                  onTap: () {
                    if (oldC.text.isEmpty ||
                        newC.text.isEmpty ||
                        confirmC.text.isEmpty) {
                      _toast('请填写完整信息');
                      return;
                    }
                    if (newC.text != confirmC.text) {
                      _toast('两次输入的新密码不一致');
                      return;
                    }
                    if (newC.text.length < 8) {
                      _toast('新密码至少 8 位');
                      return;
                    }
                    Navigator.of(sheetCtx).pop();
                    _toast('$title成功');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(24)),
                    child: const Text('确认修改',
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

  Widget _field(TextEditingController c, String hint,
          {bool obscure = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: TextField(
          controller: c,
          obscureText: obscure,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.textFaint),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

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

  Widget _nav(String label, IconData icon,
          {String? sub, Widget? trailing, VoidCallback? onTap}) =>
      PressableScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 17, color: AppColors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    if (sub != null) ...[
                      const SizedBox(height: 3),
                      Text(sub,
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textTertiary)),
                    ],
                  ]),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppColors.textFaint),
          ]),
        ),
      );

  Widget _toggle(String label, bool val, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _device(String name, String meta, bool current) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Icon(current ? LucideIcons.smartphone : LucideIcons.monitor,
              size: 17, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(meta,
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.textTertiary)),
                ]),
          ),
          if (current)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('当前',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            )
          else
            PressableScale(
              ensureHitArea: true,
              onTap: () => _toast('已移除「$name」的登录状态'),
              child: const Text('下线',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deal)),
            ),
        ]),
      );

  void _confirmDeactivate() => showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.bgElevate,
          title: const Text('注销账号',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: const Text('注销为不可逆操作。账号下的订单记录、优惠券与实名信息将被清除,确定继续吗?',
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: const Text('取消',
                    style: TextStyle(color: AppColors.textSecondary))),
            TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  _toast('注销申请已提交,客服将在 24 小时内与你确认');
                },
                child: const Text('提交注销',
                    style: TextStyle(color: Color(0xFFFF6B6B)))),
          ],
        ),
      );
}
