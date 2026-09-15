import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 绑定手机 —— 展示当前号码 + 换绑流程(验证码)。
class PhoneBindScreen extends StatefulWidget {
  final String current;
  const PhoneBindScreen({super.key, this.current = '138****1206'});

  @override
  State<PhoneBindScreen> createState() => _PhoneBindScreenState();
}

class _PhoneBindScreenState extends State<PhoneBindScreen> {
  final _phoneC = TextEditingController();
  final _codeC = TextEditingController();
  int _countdown = 0;
  Timer? _timer;
  bool _changing = false; // 是否进入换绑表单

  @override
  void dispose() {
    _timer?.cancel();
    _phoneC.dispose();
    _codeC.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  void _sendCode() {
    final p = _phoneC.text.trim();
    if (p.length < 8) {
      _toast('请输入正确的手机号');
      return;
    }
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
    _toast('验证码已发送至 $p');
  }

  void _submit() {
    if (_phoneC.text.trim().isEmpty) {
      _toast('请输入新手机号');
      return;
    }
    if (_codeC.text.trim().length < 4) {
      _toast('请输入 4-6 位验证码');
      return;
    }
    _toast('手机号换绑成功');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('绑定手机',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          // 当前绑定
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0x33E5477B), Color(0x0DE5477B)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x4DE5477B))),
            child: Column(children: [
              const Icon(LucideIcons.smartphone,
                  size: 30, color: AppColors.amber),
              const SizedBox(height: 12),
              const Text('当前绑定手机号',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              Text(widget.current,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.green),
                SizedBox(width: 5),
                Text('该号码用于登录、订单通知与出票提醒',
                    style: TextStyle(
                        fontSize: 10.5, color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          if (!_changing)
            PressableScale(
              onTap: () => setState(() => _changing = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(26)),
                child: const Text('更换手机号',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberInk)),
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Text('更换绑定',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder)),
              child: Column(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(children: [
                    const Text('+86',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: '请输入新手机号',
                          hintStyle: TextStyle(
                              fontSize: 13, color: AppColors.textFaint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ]),
                ),
                const Divider(height: 1, color: AppColors.line),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _codeC,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: '短信验证码',
                          hintStyle: TextStyle(
                              fontSize: 13, color: AppColors.textFaint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    PressableScale(
                      ensureHitArea: true,
                      onTap: _countdown > 0 ? null : _sendCode,
                      child: Opacity(
                        opacity: _countdown > 0 ? 0.45 : 1,
                        child: Text(
                            _countdown > 0 ? '重发 ${_countdown}s' : '获取验证码',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber)),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: PressableScale(
                  onTap: () => setState(() {
                    _changing = false;
                    _phoneC.clear();
                    _codeC.clear();
                  }),
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
                  onTap: _submit,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(24)),
                    child: const Text('确认换绑',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberInk)),
                  ),
                ),
              ),
            ]),
          ],
          const SizedBox(height: 20),
          const Text('换绑后原号码将无法用于登录。如原号码已停用,请联系在线客服人工核验。',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, height: 1.6, color: AppColors.textFaint)),
        ],
      ),
    );
  }
}
