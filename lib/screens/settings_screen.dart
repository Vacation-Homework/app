import 'package:flutter/material.dart';
import 'package:vacation_homework_app/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? nickname;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final result = await UserService.fetchNickname();
    setState(() {
      nickname = result ?? 'ERROR';
      isLoading = false;
    });
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: nickname ?? '');
    bool hasShownSnackbar = false;

    controller.addListener(() {
      if (controller.text.length > 5) {
        controller.text = controller.text.substring(0, 5);
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        if (!hasShownSnackbar) {
          hasShownSnackbar = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('닉네임은 최대 5글자까지 가능합니다.')),
          );
        }
      }
    });

    final newNickname = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 닉네임 입력'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('확인')),
        ],
      ),
    );

    if (newNickname != null && newNickname.trim().isNotEmpty) {
      final success = await UserService.updateNickname(newNickname);
      if (success) {
        setState(() => nickname = newNickname);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임이 변경되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('변경 실패')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final success = await UserService.logout();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃 실패')),
        );
      }
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _withdraw() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말로 탈퇴하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('탈퇴')),
        ],
      ),
    );

    if (confirm == true) {
      final result = await UserService.withdraw();
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('설정'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(nickname!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Divider(),
                _buildTapRow('닉네임 변경', _editNickname),
                const Divider(),
                _buildTapRow('로그아웃', _logout),
                const Divider(),
                _buildTapRow('회원탈퇴', _withdraw),
                const Divider(),
              ],
            ),
    );
  }

  Widget _buildTapRow(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
