import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 出行人 / 证件管理 —— 观演实名 + 港区通行证件。支持新增/编辑/删除/设为默认。
class TravelerScreen extends StatefulWidget {
  const TravelerScreen({super.key});

  @override
  State<TravelerScreen> createState() => _TravelerScreenState();
}

class _Person {
  String name;
  String idType;
  String idNo;
  bool isDefault;
  _Person(this.name, this.idType, this.idNo, this.isDefault);
}

class _TravelerScreenState extends State<TravelerScreen> {
  static const _idTypes = ['港澳通行证', '身份证', '护照', '回乡证'];

  final List<_Person> _people = [
    _Person('王小明', '港澳通行证', 'C1234****89', true),
    _Person('李静', '身份证', '440305********1024', false),
    _Person('Wang Lei', '护照', 'E8****321', false),
  ];

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  void _setDefault(int i) {
    if (_people[i].isDefault) return;
    setState(() {
      for (var p in _people) {
        p.isDefault = false;
      }
      _people[i].isDefault = true;
    });
    _toast('已设为默认出行人');
  }

  void _delete(int i) {
    final removed = _people[i];
    setState(() {
      _people.removeAt(i);
      if (removed.isDefault && _people.isNotEmpty) {
        _people.first.isDefault = true;
      }
    });
    _toast('已删除该出行人');
  }

  Future<void> _editSheet({int? index}) async {
    final editing = index != null;
    final p = editing ? _people[index] : null;
    final nameC = TextEditingController(text: p?.name ?? '');
    final idNoC = TextEditingController(text: p?.idNo ?? '');
    String idType = p?.idType ?? _idTypes.first;
    bool asDefault = p?.isDefault ?? _people.isEmpty;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (_, setSheet) => Container(
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
              Text(editing ? '编辑出行人' : '新增出行人',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              _field(nameC, '姓名(与证件一致)', LucideIcons.user),
              const SizedBox(height: 14),
              // 证件类型选择
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('证件类型',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _idTypes)
                    PressableScale(
                      onTap: () => setSheet(() => idType = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            gradient: idType == t
                                ? AppColors.amberGradient
                                : null,
                            color: idType == t ? null : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: idType == t
                                    ? Colors.transparent
                                    : AppColors.cardBorder)),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: idType == t
                                    ? AppColors.amberInk
                                    : AppColors.textSecondary)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _field(idNoC, '证件号码', LucideIcons.idCard),
              const SizedBox(height: 14),
              PressableScale(
                onTap: () => setSheet(() => asDefault = !asDefault),
                child: Row(children: [
                  Icon(
                      asDefault
                          ? LucideIcons.circleCheckBig
                          : LucideIcons.circle,
                      size: 17,
                      color: asDefault ? AppColors.amber : AppColors.textFaint),
                  const SizedBox(width: 8),
                  const Text('设为默认出行人',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ]),
              ),
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
                      if (nameC.text.trim().isEmpty ||
                          idNoC.text.trim().isEmpty) {
                        _toast('请填写姓名与证件号码');
                        return;
                      }
                      setState(() {
                        if (asDefault) {
                          for (var x in _people) {
                            x.isDefault = false;
                          }
                        }
                        if (editing) {
                          final t = _people[index];
                          t.name = nameC.text.trim();
                          t.idType = idType;
                          t.idNo = idNoC.text.trim();
                          t.isDefault = asDefault;
                        } else {
                          _people.add(_Person(nameC.text.trim(), idType,
                              idNoC.text.trim(), asDefault));
                        }
                        if (!_people.any((x) => x.isDefault) &&
                            _people.isNotEmpty) {
                          _people.first.isDefault = true;
                        }
                      });
                      Navigator.of(sheetCtx).pop();
                      _toast(editing ? '出行人已更新' : '出行人已添加');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(24)),
                      child: Text(editing ? '保存' : '添加',
                          style: const TextStyle(
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
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: c,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.textFaint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text('出行人 / 证件',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        _tip(),
        Expanded(
          child: _people.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: _people.length,
                  itemBuilder: (_, i) => _card(i),
                ),
        ),
        _addBar(),
      ]),
    );
  }

  Widget _tip() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.amber.withValues(alpha: 0.3))),
          child: Row(children: const [
            Icon(LucideIcons.info, size: 15, color: AppColors.amber),
            SizedBox(width: 10),
            Expanded(
              child: Text('部分演出需实名入场,请确保证件与购票人一致。港区观演建议备好港澳通行证。',
                  style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: AppColors.textSecondary)),
            ),
          ]),
        ),
      );

  Widget _empty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.userPlus, size: 40, color: AppColors.amber),
          SizedBox(height: 14),
          Text('还没有添加出行人',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('提前添加证件信息,下单实名更快捷',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ]),
      );

  Widget _card(int i) {
    final p = _people[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: p.isDefault
                    ? const Color(0x66E5477B)
                    : AppColors.cardBorder)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                if (p.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('默认',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amber)),
                  ),
                const Spacer(),
                PressableScale(
                  ensureHitArea: true,
                  onTap: () => _editSheet(index: i),
                  child: const Icon(LucideIcons.pencil,
                      size: 16, color: AppColors.textTertiary),
                ),
                const SizedBox(width: 14),
                PressableScale(
                  ensureHitArea: true,
                  onTap: () => _confirmDelete(i),
                  child: const Icon(LucideIcons.trash2,
                      size: 16, color: AppColors.textTertiary),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(LucideIcons.idCard,
                    size: 14, color: AppColors.textFaint),
                const SizedBox(width: 8),
                Text('${p.idType}  ',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
                Text(p.idNo,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 12),
              PressableScale(
                onTap: () => _setDefault(i),
                child: Row(children: [
                  Icon(
                      p.isDefault
                          ? LucideIcons.circleCheckBig
                          : LucideIcons.circle,
                      size: 15,
                      color:
                          p.isDefault ? AppColors.amber : AppColors.textFaint),
                  const SizedBox(width: 6),
                  Text(p.isDefault ? '默认出行人' : '设为默认',
                      style: TextStyle(
                          fontSize: 12,
                          color: p.isDefault
                              ? AppColors.amber
                              : AppColors.textTertiary)),
                ]),
              ),
            ]),
      ),
    );
  }

  Future<void> _confirmDelete(int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.bgElevate,
        title: const Text('删除出行人',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text('确定删除出行人「${_people[i].name}」吗?',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('取消',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child:
                  const Text('删除', style: TextStyle(color: AppColors.deal))),
        ],
      ),
    );
    if (ok == true) _delete(i);
  }

  Widget _addBar() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: PressableScale(
            onTap: () => _editSheet(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(26)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.plus, size: 18, color: AppColors.amberInk),
                    SizedBox(width: 6),
                    Text('新增出行人',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberInk)),
                  ]),
            ),
          ),
        ),
      );
}
