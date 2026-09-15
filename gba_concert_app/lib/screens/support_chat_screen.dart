import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 在线客服会话 —— 对话气泡 + 快捷问题 + 输入栏(mock)。后端接口预留。
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _input = TextEditingController();
  // [是否客服(true)/用户(false), 文本]
  final List<List<Object>> _msgs = [
    [true, '你好,我是穩飛客服小飛 👋 请问有什么可以帮你?'],
    [true, '你可以直接点下方常见问题,或输入你的问题。'],
  ];
  static const _quick = ['我的票什么时候出?', '怎么申请退款?', '实体票怎么收?', '演出改期了怎么办?'];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _msgs.add([false, text.trim()]);
      _input.clear();
      _msgs.add([true, '收到你的问题「$text」,客服正在为你查询,请稍候…']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('在线客服',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: AppColors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          const Text('在线',
              style: TextStyle(fontSize: 11, color: AppColors.green)),
        ]),
        centerTitle: false,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              ..._msgs.map((m) => _bubble(m[0] as bool, m[1] as String)),
            ],
          ),
        ),
        _quickBar(),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(bool agent, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
            mainAxisAlignment:
                agent ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (agent) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      shape: BoxShape.circle),
                  child: const Icon(LucideIcons.headset,
                      size: 16, color: AppColors.amberInk),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      gradient: agent ? null : AppColors.amberGradient,
                      color: agent ? AppColors.card : null,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(agent ? 4 : 14),
                          bottomRight: Radius.circular(agent ? 14 : 4)),
                      border: agent
                          ? Border.all(color: AppColors.cardBorder)
                          : null),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: agent
                              ? AppColors.textPrimary
                              : AppColors.amberInk)),
                ),
              ),
            ]),
      );

  Widget _quickBar() => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _quick
              .map((q) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PressableScale(
                      onTap: () => _send(q),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.4))),
                        child: Text(q,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.amber)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _inputBar() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          decoration: const BoxDecoration(
              color: AppColors.bgElevate,
              border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder)),
                child: TextField(
                  controller: _input,
                  onSubmitted: _send,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '输入你的问题…',
                      hintStyle: TextStyle(color: AppColors.textFaint)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            PressableScale(
              onTap: () => _send(_input.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    shape: BoxShape.circle),
                child: const Icon(LucideIcons.send,
                    size: 18, color: AppColors.amberInk),
              ),
            ),
          ]),
        ),
      );
}
