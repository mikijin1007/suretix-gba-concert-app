import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// 登录/注册 —— 手机号 + 验证码(mock)。后端接口预留。
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _agree = false;
  int _countdown = 0;

  bool get _canLogin =>
      _phone.text.length >= 11 && _code.text.length >= 4 && _agree;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_phone.text.length < 11) return;
    setState(() => _countdown = 60);
    // mock 倒计时
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
  }

  void _login() {
    if (!_canLogin) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PressableScale(
                    ensureHitArea: true,
                    onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainShell())),
                    child: const Text('跳过',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textTertiary)),
                  ),
                ),
                const SizedBox(height: 40),
                _brand(),
                const SizedBox(height: 44),
                _phoneField(),
                const SizedBox(height: 14),
                _codeField(),
                const SizedBox(height: 28),
                _loginBtn(),
                const SizedBox(height: 18),
                _agreeRow(),
                const Spacer(),
                _otherLogins(),
              ]),
        ),
      ),
    );
  }

  Widget _brand() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.ticket,
                size: 24, color: AppColors.amberInk),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('穩飛 SureTix',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('担保出票 · 一站式观演',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ]),
        ]),
        const SizedBox(height: 20),
        Text('登录 / 注册',
            style: AppTheme.displaySerif(size: 30)),
        const SizedBox(height: 6),
        const Text('未注册手机号将自动创建账号',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]);

  Widget _phoneField() => Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          const Text('+86',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.line,
          ),
          Expanded(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: '请输入手机号',
                  hintStyle: TextStyle(color: AppColors.textFaint)),
            ),
          ),
        ]),
      );

  Widget _codeField() => Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: '验证码',
                  hintStyle: TextStyle(color: AppColors.textFaint)),
            ),
          ),
          PressableScale(
            onTap: _countdown > 0 ? null : _sendCode,
            child: Text(_countdown > 0 ? '${_countdown}s 后重发' : '获取验证码',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _countdown > 0 ? AppColors.textFaint : AppColors.amber)),
          ),
        ]),
      );

  Widget _loginBtn() => PressableScale(
        onTap: _login,
        child: Opacity(
          opacity: _canLogin ? 1 : 0.45,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ]),
            child: const Text('登录',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amberInk)),
          ),
        ),
      );

  Widget _agreeRow() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PressableScale(
          ensureHitArea: true,
          onTap: () => setState(() => _agree = !_agree),
          child: Icon(
              _agree ? LucideIcons.squareCheckBig : LucideIcons.square,
              size: 16,
              color: _agree ? AppColors.amber : AppColors.textTertiary),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text.rich(TextSpan(
              text: '登录即代表同意 ',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.5),
              children: [
                TextSpan(text: '《购票服务协议》',
                    style: TextStyle(color: AppColors.amber)),
                TextSpan(text: ' 与 '),
                TextSpan(text: '《隐私政策》',
                    style: TextStyle(color: AppColors.amber)),
              ])),
        ),
      ]);

  Widget _otherLogins() => Column(children: [
        Row(children: [
          const Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('其他方式登录',
                style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
          ),
          const Expanded(child: Divider(color: AppColors.line)),
        ]),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _oauth(LucideIcons.messageCircle, '微信'),
          const SizedBox(width: 32),
          _oauth(LucideIcons.apple, 'Apple'),
        ]),
      ]);

  Widget _oauth(IconData icon, String label) => PressableScale(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('正在跳转 $label 授权登录…'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )),
        child: Column(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder)),
            child: Icon(icon, size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ]),
      );
}
