import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 收货地址管理 —— 顺丰票根寄送用。支持新增/编辑/删除/设为默认。
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _Addr {
  String name;
  String phone;
  String detail;
  bool isDefault;
  _Addr(this.name, this.phone, this.detail, this.isDefault);
}

class _AddressScreenState extends State<AddressScreen> {
  final List<_Addr> _addrs = [
    _Addr('王小明', '138****1206', '广东省深圳市南山区科技园南路 XX 号 XX 大厦 2801', true),
    _Addr('李静', '139****8890', '广东省广州市天河区天河路 XX 号 XX 花园 3 栋 1502', false),
  ];

  void _setDefault(int i) {
    if (_addrs[i].isDefault) return;
    setState(() {
      for (var a in _addrs) {
        a.isDefault = false;
      }
      _addrs[i].isDefault = true;
    });
    _toast('已设为默认地址');
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

  void _delete(int i) {
    final removed = _addrs[i];
    setState(() {
      _addrs.removeAt(i);
      // 删掉默认地址后,自动把第一条设为默认
      if (removed.isDefault && _addrs.isNotEmpty) _addrs.first.isDefault = true;
    });
    _toast('已删除该地址');
  }

  // 新增/编辑表单
  Future<void> _editSheet({int? index}) async {
    final editing = index != null;
    final a = editing ? _addrs[index] : null;
    final nameC = TextEditingController(text: a?.name ?? '');
    final phoneC = TextEditingController(text: a?.phone ?? '');
    final detailC = TextEditingController(text: a?.detail ?? '');
    bool asDefault = a?.isDefault ?? _addrs.isEmpty;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
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
              Text(editing ? '编辑收货地址' : '新增收货地址',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              _field(nameC, '收件人姓名', LucideIcons.user),
              const SizedBox(height: 12),
              _field(phoneC, '手机号码', LucideIcons.phone,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _field(detailC, '详细地址(省市区 + 街道门牌)', LucideIcons.mapPin,
                  maxLines: 2),
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
                  const Text('设为默认地址',
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
                          phoneC.text.trim().isEmpty ||
                          detailC.text.trim().isEmpty) {
                        _toast('请填写完整的收件信息');
                        return;
                      }
                      setState(() {
                        if (asDefault) {
                          for (var x in _addrs) {
                            x.isDefault = false;
                          }
                        }
                        if (editing) {
                          final t = _addrs[index];
                          t.name = nameC.text.trim();
                          t.phone = phoneC.text.trim();
                          t.detail = detailC.text.trim();
                          t.isDefault = asDefault;
                        } else {
                          _addrs.add(_Addr(nameC.text.trim(),
                              phoneC.text.trim(), detailC.text.trim(),
                              asDefault));
                        }
                        // 保证至少有一个默认地址
                        if (!_addrs.any((x) => x.isDefault) &&
                            _addrs.isNotEmpty) {
                          _addrs.first.isDefault = true;
                        }
                      });
                      Navigator.of(sheetCtx).pop();
                      _toast(editing ? '地址已更新' : '地址已添加');
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

  Widget _field(TextEditingController c, String hint, IconData icon,
          {TextInputType? keyboard, int maxLines = 1}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: keyboard,
              maxLines: maxLines,
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
        title: const Text('收货地址',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(children: [
        Expanded(
          child: _addrs.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: _addrs.length,
                  itemBuilder: (_, i) => _card(i),
                ),
        ),
        _addBar(),
      ]),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(LucideIcons.mapPinOff, size: 40, color: AppColors.amber),
          SizedBox(height: 14),
          Text('还没有收货地址',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('添加地址后,实体票可通过顺丰保价寄送到手',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ]),
      );

  Widget _card(int i) {
    final a = _addrs[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: a.isDefault
                    ? const Color(0x66E5477B)
                    : AppColors.cardBorder)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(a.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                Text(a.phone,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
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
              const SizedBox(height: 10),
              Text(a.detail,
                  style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              PressableScale(
                onTap: () => _setDefault(i),
                child: Row(children: [
                  Icon(
                      a.isDefault
                          ? LucideIcons.circleCheckBig
                          : LucideIcons.circle,
                      size: 15,
                      color:
                          a.isDefault ? AppColors.amber : AppColors.textFaint),
                  const SizedBox(width: 6),
                  Text(a.isDefault ? '默认地址' : '设为默认',
                      style: TextStyle(
                          fontSize: 12,
                          color: a.isDefault
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
        title: const Text('删除地址',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text('确定删除「${_addrs[i].name}」的收货地址吗?',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('取消',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('删除',
                  style: TextStyle(color: AppColors.deal))),
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
                    Text('新增收货地址',
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
