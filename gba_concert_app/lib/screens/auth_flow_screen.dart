import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

// =============================================================
// 稳飞 SureTix · 登录/注册/引导全流程（15 屏，粉色主题）
// 改编自 Figma MovieTime 模板：紫色→玫红粉，流媒体→观演票务
//   Intro(3) → SignIn / SignUp / SignUpEmail → VerifyOtp
//   → SetPassword → AddPicture → WhoWatching
//   → Setup 向导(偏好→头像→套餐)
// =============================================================

const _kPageBg = Color(0xFF0A0A0B);

// 顶部粉色微光渐变背景(左上粉光过渡到黑)
const _authGlowBg = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF3A1626), Color(0xFF1C0E17), Color(0xFF0A0A0B)],
  stops: [0.0, 0.32, 0.6],
);

// 共享：认证页全屏背景图（登录页同款）
const _authBgDecoration = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/auth_bg.jpg'),
    fit: BoxFit.cover,
  ),
);

// 共享：靠左返回箭头行（圆形按钮，与登录页统一）
Widget authBackRow(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: PressableScale(
        ensureHitArea: true,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder)),
          child: const Icon(LucideIcons.chevronLeft,
              size: 20, color: AppColors.textPrimary),
        ),
      ),
    );

// 共享：登录页样式标题（大号粗体，非书法体）
Widget authTitle(String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
      ],
    );

// 共享：底部 logo 水印（登录页同款）
Widget authLogoFooter() => Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      child: Center(
        child: Opacity(
          opacity: 0.35,
          child: Image.asset('assets/images/logo_full.png',
              height: 96, fit: BoxFit.contain),
        ),
      ),
    );

// 共享：粉色图片按钮（按钮.png 素材 + 居中文字，登录页同款）
Widget authImageButton(String label, VoidCallback? onTap, {bool enabled = true}) =>
    PressableScale(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: AspectRatio(
          aspectRatio: 1404 / 296,
          child: Stack(children: [
            Positioned.fill(
              child: Image.asset('assets/images/btn_login.png',
                  fit: BoxFit.fill),
            ),
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -5),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );

/// 主渐变按钮（粉色）
class _GradButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  const _GradButton(this.label, {this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.amberGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.4),
                  blurRadius: 22,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

/// 顶部步骤进度条（Setup 向导用）
class _StepBar extends StatelessWidget {
  final int total;
  final int current;
  const _StepBar({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              gradient: on ? AppColors.amberGradient : null,
              color: on ? null : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// 深色输入框
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscure;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboard;
  final String? error;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.controller,
    required this.hint,
    this.label,
    this.obscure = false,
    this.prefix,
    this.suffix,
    this.keyboard,
    this.error,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) ...[
        Text(label!,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
      ],
      Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: hasError ? const Color(0xFFFF5A6A) : AppColors.cardBorder)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          if (prefix != null) ...[prefix!, const SizedBox(width: 10)],
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboard,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textFaint)),
            ),
          ),
          if (suffix != null) suffix!,
        ]),
      ),
      if (hasError) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(LucideIcons.circleAlert, size: 13, color: Color(0xFFFF5A6A)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(error!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFFFF5A6A))),
          ),
        ]),
      ],
    ]);
  }
}

// =============================================================
// 引导页 Intro（3 屏全屏海报轮播）—— 入口
// =============================================================
class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  final _pc = PageController();
  int _page = 0;

  // [海报图, 大标题, 副标题]
  static const _slides = [
    [
      'assets/images/concert_1.jpg',
      '看演出\n这样最省心',
      '演唱会、音乐节、话剧一站式购票\n担保出票，官方售罄也有票',
    ],
    [
      'assets/images/concert_3.jpg',
      '担保出票\n跳票我们赔',
      '下单即锁票源，48 小时内出票\n逾期未出全额退款并补偿',
    ],
    [
      'assets/images/concert_6.jpg',
      '现场兜底\n进不去就赔',
      '实体票实拍可见，入场无忧\n一键应急客服全程护航',
    ],
  ];

  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  void _startAutoplay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pc.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _pc.animateToPage(next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  void _toSignIn() => AppRoute.to(context, const SignInScreen());
  void _toSignUp() => AppRoute.to(context, const SignUpScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Stack(children: [
        // 全屏海报轮播
        PageView.builder(
          controller: _pc,
          onPageChanged: (i) {
            setState(() => _page = i);
            _startAutoplay(); // 手动滑动后重置计时，避免与用户操作冲突
          },
          itemCount: _slides.length,
          itemBuilder: (_, i) => _poster(_slides[i][0]),
        ),
        // 全屏黑色遮罩(50% 不透明度)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        // 底部内容 scrim + 文案 + 按钮
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
            decoration: BoxDecoration(gradient: AppColors.scrim()),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dots(),
              const SizedBox(height: 24),
              Text(_slides[_page][1],
                  textAlign: TextAlign.center,
                  style: AppTheme.displaySerif(size: 32)),
              const SizedBox(height: 14),
              Text(_slides[_page][2],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.7, color: Color(0xFFD8D8DC))),
              const SizedBox(height: 30),
              _GradButton('登录', onTap: _toSignIn),
              const SizedBox(height: 14),
              PressableScale(
                onTap: _toSignUp,
                child: RichText(
                  text: const TextSpan(
                    text: '还没有账号？ ',
                    style: TextStyle(fontSize: 13, color: Color(0xFFB8B8BC)),
                    children: [
                      TextSpan(
                          text: '立即注册',
                          style: TextStyle(
                              color: AppColors.amberBright,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
        // 中上部居中 logo
        Positioned(
          top: MediaQuery.of(context).size.height * 0.17,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset('assets/images/logo_full.png',
                height: 144, fit: BoxFit.contain),
          ),
        ),
      ]),
    );
  }

  Widget _poster(String path) => Stack(fit: StackFit.expand, children: [
        Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A0512), Color(0xFF0A0A0B)],
              ),
            ),
          );
        }),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.15), Colors.transparent],
              stops: const [0, 0.4],
            ),
          ),
        ),
      ]);

  Widget _dots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (i) {
          final on = _page == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: on ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
                gradient: on ? AppColors.amberGradient : null,
                color: on ? null : Colors.white24,
                borderRadius: BorderRadius.circular(4)),
          );
        }),
      );
}

// =============================================================
// 登录 Sign in（复刻 Figma：手机号+区号 / or Email / 密码 / 忘记密码 / Sign in）
// =============================================================
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  // 登录：输入密码后直接进主页（验证码/设密码/头像/引导仅用于注册流程）
  void _signIn() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              children: [
                const SizedBox(height: 80),
                const Center(
                  child: Text('欢迎回来！',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('请使用手机号登录',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 60),
                // 手机号 label
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('手机号',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                _phoneWithCode(),
                const SizedBox(height: 32),
                // or 邮箱地址
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('或 邮箱地址',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                _plainField(_email, 'ryananderson@sth.com',
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _plainField(_pwd, '••••••••••••',
                    obscure: _obscure,
                    suffix: PressableScale(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                          _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 18,
                          color: AppColors.amber),
                    )),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: PressableScale(
                    ensureHitArea: true,
                    onTap: () =>
                        AppRoute.to(context, const SetPasswordScreen()),
                    child: const Text('忘记密码？',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textTertiary)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: authImageButton('登录', _signIn),
          ),
          const SizedBox(height: 8),
          Center(
            child: PressableScale(
              ensureHitArea: true,
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignUpScreen())),
              child: RichText(
                text: const TextSpan(
                  text: '还没有账号？ ',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textTertiary),
                  children: [
                    TextSpan(
                        text: '去注册',
                        style: TextStyle(
                            color: AppColors.amberBright,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
            child: Center(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset('assets/images/logo_full.png',
                    height: 96, fit: BoxFit.contain),
              ),
            ),
          ),
        ]),
        ),
      ),
    );
  }

  // 区号选择器 + 手机号（左右两段，中间竖线）
  Widget _phoneWithCode() => Container(
        height: 56,
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Text('+86',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              SizedBox(width: 4),
              Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textTertiary),
            ]),
          ),
          Container(width: 1, height: 24, color: AppColors.line),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '138 0000 0000',
                    hintStyle: TextStyle(color: AppColors.textFaint)),
              ),
            ),
          ),
        ]),
      );

  Widget _plainField(TextEditingController c, String hint,
          {bool obscure = false,
          Widget? suffix,
          TextInputType? keyboard}) =>
      Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: c,
              obscureText: obscure,
              keyboardType: keyboard,
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textFaint)),
            ),
          ),
          if (suffix != null) suffix,
        ]),
      );
}

// =============================================================
// 注册 Sign up（第三方 + 邮箱入口）
// =============================================================
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 120),
              const Center(
                child: Text('注册',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text('创建你的穩飛账号',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 56),
              // 主按钮：使用邮箱继续（粉色图片按钮）
              authImageButton('使用邮箱继续',
                  () => AppRoute.to(context, const SignUpEmailScreen())),
              const SizedBox(height: 24),
              // 分割线：其他方式
              Row(children: const [
                Expanded(child: Divider(color: AppColors.line)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('其他方式',
                      style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
                ),
                Expanded(child: Divider(color: AppColors.line)),
              ]),
              const SizedBox(height: 24),
              _oauthWide(context, 'assets/images/icon_google.svg',
                  '使用 Google 注册'),
              const SizedBox(height: 14),
              _oauthWide(context, null, '使用 Facebook 注册',
                  fallbackText: 'f'),
              const SizedBox(height: 14),
              _oauthWide(context, 'assets/images/icon_apple.svg',
                  '使用 Apple 注册'),
              const Spacer(),
              Center(
                child: PressableScale(
                  onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignInScreen())),
                  child: RichText(
                    text: const TextSpan(
                      text: '已有账号？ ',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      children: [
                        TextSpan(
                            text: '立即登录',
                            style: TextStyle(
                                color: AppColors.amberBright,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _oauthWide(BuildContext context, String? svgPath, String label,
      {String? fallbackText}) {
    return PressableScale(
      // 第三方注册跳过验证码，直接设置密码
      onTap: () => AppRoute.to(context, const SetPasswordScreen()),
      child: Container(
        width: double.infinity,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (svgPath != null) ...[
            SvgPicture.asset(svgPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary, BlendMode.srcIn)),
            const SizedBox(width: 12),
          ] else if (fallbackText != null) ...[
            Text(fallbackText,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 12),
          ],
          Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// =============================================================
// 邮箱注册 Sign up-email（姓名/邮箱/密码 + 协议）+ 错误态
// =============================================================
class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});
  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  bool _agree = false;
  bool _obscure = true;
  bool _obscure2 = true;
  String? _emailErr;
  String? _pwdErr;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  void _signUp() {
    setState(() {
      _emailErr = _email.text.contains('@') ? null : '邮箱格式不正确';
      if (_pwd.text.length < 8) {
        _pwdErr = '密码太弱，请使用至少 8 位数字与字母组合';
      } else if (_pwd.text != _pwd2.text) {
        _pwdErr = '两次输入的密码不一致';
      } else {
        _pwdErr = null;
      }
    });
    if (_emailErr == null && _pwdErr == null && _agree) {
      AppRoute.to(context, const VerifyOtpScreen());
    }
  }

  // 带图标 + label 的字段（参考图 Sign Up 版式）
  Widget _iconField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: hasError
                    ? const Color(0xFFFF5A6A)
                    : AppColors.cardBorder)),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboard,
              onChanged: onChanged,
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textFaint)),
            ),
          ),
          if (suffix != null) suffix,
        ]),
      ),
      if (hasError) ...[
        const SizedBox(height: 6),
        Text(error,
            style:
                const TextStyle(fontSize: 11.5, color: Color(0xFFFF5A6A))),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
          child: Column(children: [
            // 顶部：圆形返回 + 居中标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Stack(alignment: Alignment.center, children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: PressableScale(
                    ensureHitArea: true,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder)),
                      child: const Icon(LucideIcons.chevronLeft,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const Text('注册',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
                children: [
                  const Text('创建你的账号',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 28),
                  _iconField(
                      icon: LucideIcons.user,
                      label: '姓名',
                      controller: _name,
                      hint: '请输入姓名'),
                  const SizedBox(height: 20),
                  _iconField(
                    icon: LucideIcons.mail,
                    label: '邮箱',
                    controller: _email,
                    hint: '请输入邮箱',
                    keyboard: TextInputType.emailAddress,
                    error: _emailErr,
                    onChanged: (_) => setState(() => _emailErr = null),
                  ),
                  const SizedBox(height: 20),
                  _iconField(
                    icon: LucideIcons.lock,
                    label: '设置密码',
                    controller: _pwd,
                    hint: '至少 8 位',
                    obscure: _obscure,
                    error: _pwdErr,
                    onChanged: (_) => setState(() => _pwdErr = null),
                    suffix: PressableScale(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                          _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 18,
                          color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _iconField(
                    icon: LucideIcons.lock,
                    label: '确认密码',
                    controller: _pwd2,
                    hint: '再次输入密码',
                    obscure: _obscure2,
                    onChanged: (_) => setState(() => _pwdErr = null),
                    suffix: PressableScale(
                      onTap: () => setState(() => _obscure2 = !_obscure2),
                      child: Icon(
                          _obscure2 ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 18,
                          color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    PressableScale(
                      ensureHitArea: true,
                      onTap: () => setState(() => _agree = !_agree),
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: _agree ? AppColors.amberGradient : null,
                            color: _agree ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _agree
                                    ? Colors.transparent
                                    : AppColors.textTertiary)),
                        child: _agree
                            ? const Icon(LucideIcons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text.rich(TextSpan(
                        text: '我已阅读并同意 ',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                              text: '服务条款',
                              style: TextStyle(
                                  color: AppColors.amberBright,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.amberBright)),
                        ])),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 4),
              child: authImageButton('注册', _signUp, enabled: _agree),
            ),
            const SizedBox(height: 10),
            Center(
              child: PressableScale(
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen())),
                child: RichText(
                  text: const TextSpan(
                    text: '已有账号？ ',
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    children: [
                      TextSpan(
                          text: '立即登录',
                          style: TextStyle(
                              color: AppColors.amberBright,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}

// =============================================================
// 验证码 Verify OTP（6 格）
// =============================================================
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<String> _digits = List.filled(4, '');
  int _countdown = 30;
  Timer? _timer;
  final _focus = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _complete => _digits.every((d) => d.isNotEmpty);
  int get _cursor => _digits.indexWhere((d) => d.isEmpty);

  void _onChanged(String v) {
    final chars = v.replaceAll(RegExp(r'[^0-9]'), '').split('');
    setState(() {
      for (var i = 0; i < 4; i++) {
        _digits[i] = i < chars.length ? chars[i] : '';
      }
    });
    if (_complete) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) AppRoute.to(context, const SetPasswordScreen());
      });
    }
  }

  String get _mmss {
    final m = (_countdown ~/ 60).toString().padLeft(2, '0');
    final s = (_countdown % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
        child: Column(children: [
          // 顶部：圆角返回按钮 + 居中标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Stack(alignment: Alignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PressableScale(
                  ensureHitArea: true,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: const Icon(LucideIcons.chevronLeft,
                        size: 20, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const Text('验证 OTP',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
          ),
          const SizedBox(height: 56),
          const Text('验证码',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          const Text('验证码已发送至 +86 138 0000 000',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          PressableScale(
            ensureHitArea: true,
            onTap: () => Navigator.of(context).maybePop(),
            child: const Text('修改手机号',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberBright,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.amberBright)),
          ),
          const SizedBox(height: 56),
          // 4 格验证码（居中）
          Stack(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == _cursor;
                final filled = _digits[i].isNotEmpty;
                return Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (active || filled)
                            ? AppColors.amber
                            : AppColors.cardBorder,
                        width: (active || filled) ? 1.5 : 1),
                  ),
                  child: Text(_digits[i],
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  focusNode: _focus,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  onChanged: _onChanged,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          // 闹钟 + 倒计时
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.alarmClock, size: 18, color: AppColors.amber),
            const SizedBox(width: 8),
            Text(_mmss,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 28),
          PressableScale(
            ensureHitArea: true,
            onTap: _countdown > 0 ? null : _startCountdown,
            child: RichText(
              text: TextSpan(
                text: '没收到验证码？ ',
                style: const TextStyle(
                    fontSize: 13.5, color: AppColors.textTertiary),
                children: [
                  TextSpan(
                      text: '重新发送',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _countdown > 0
                              ? AppColors.textFaint
                              : AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 62),
            child: authImageButton('验证',
                () => AppRoute.to(context, const SetPasswordScreen()),
                enabled: _complete),
          ),
        ]),
        ),
      ),
    );
  }
}

// =============================================================
// 设置密码 Set password（新密码 + 确认）
// =============================================================
class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});
  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _o1 = true, _o2 = true;
  String? _err;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      if (_p1.text.length < 8) {
        _err = '密码至少 8 位';
      } else if (_p1.text != _p2.text) {
        _err = '两次输入的密码不一致';
      } else {
        _err = null;
      }
    });
    if (_err == null) AppRoute.to(context, const AddPictureScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          children: [
            authBackRow(context),
            const SizedBox(height: 32),
            authTitle('设置新密码', '为账号设置一个安全的登录密码'),
            const SizedBox(height: 48),
            _Field(
              controller: _p1,
              label: '新密码',
              hint: '输入新密码（至少 8 位）',
              obscure: _o1,
              error: _err,
              onChanged: (_) => setState(() => _err = null),
              suffix: PressableScale(
                onTap: () => setState(() => _o1 = !_o1),
                child: Icon(_o1 ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 24),
            _Field(
              controller: _p2,
              label: '确认新密码',
              hint: '再次输入新密码',
              obscure: _o2,
              onChanged: (_) => setState(() => _err = null),
              suffix: PressableScale(
                onTap: () => setState(() => _o2 = !_o2),
                child: Icon(_o2 ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 32),
            authImageButton('确认', _submit),
            const SizedBox(height: 14),
            Center(
              child: PressableScale(
                ensureHitArea: true,
                onTap: () => Navigator.of(context).maybePop(),
                child: const Text('取消',
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ),
            ),
            const SizedBox(height: 20),
            authLogoFooter(),
          ],
        ),
        ),
      ),
    );
  }
}

// =============================================================
// 添加头像 Add profile picture
// =============================================================
class AddPictureScreen extends StatelessWidget {
  const AddPictureScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Column(children: [
            Row(children: [
              const AppBackButton(),
              const Spacer(),
              PressableScale(
                ensureHitArea: true,
                onTap: () => AppRoute.to(context, const UsernameScreen()),
                child: const Text('稍后',
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              ),
            ]),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: authTitle('欢迎！', '添加头像，完善你的个人资料'),
            ),
            const SizedBox(height: 60),
            Stack(children: [
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.amber, width: 2.5),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(28),
                child: Image.asset('assets/images/avatar_face.png',
                    fit: BoxFit.contain),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kPageBg, width: 3),
                  ),
                  child: const Icon(LucideIcons.camera,
                      size: 19, color: Colors.white),
                ),
              ),
            ]),
            const Spacer(),
            authImageButton('下一步',
                () => AppRoute.to(context, const UsernameScreen())),
          ]),
        ),
        ),
      ),
    );
  }
}

// =============================================================
// 填写用户名 Username（注册最后一步 → 进主页）
// =============================================================
class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});
  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _name = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _finish() {
    if (_name.text.trim().isEmpty) {
      setState(() => _err = '请填写用户名');
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: Container(
        decoration: _authBgDecoration,
        child: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
                children: [
                  authBackRow(context),
                  const SizedBox(height: 32),
                  authTitle('设置用户名', '取一个昵称，方便大家认识你'),
                  const SizedBox(height: 48),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text('用户名',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _err != null
                                ? const Color(0xFFFF5A6A)
                                : AppColors.cardBorder)),
                    child: Row(children: [
                      const Icon(LucideIcons.user,
                          size: 18, color: AppColors.textTertiary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _name,
                          onChanged: (_) => setState(() => _err = null),
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: '请输入用户名',
                              hintStyle:
                                  TextStyle(color: AppColors.textFaint)),
                        ),
                      ),
                    ]),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(_err!,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFFFF5A6A))),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: authImageButton('完成', _finish),
            ),
          ]),
        ),
      ),
    );
  }
}
