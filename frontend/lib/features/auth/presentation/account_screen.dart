import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/error_message.dart';
import 'auth_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _nicknameController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2) {
      _showMessage('닉네임은 2자 이상이어야 합니다.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authSessionProvider.notifier).updateNickname(nickname);
      if (mounted) _showMessage('닉네임을 변경했습니다.');
    } catch (error) {
      if (mounted) _showMessage(userErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계정은 논리적으로 삭제되고 개인정보는 익명화됩니다. '
              '가챠 및 커뮤니티 감사 로그는 사용자 ID 기준으로 유지됩니다.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: '현재 비밀번호'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, passwordController.text),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty) return;
    try {
      await ref.read(authSessionProvider.notifier).deleteAccount(password);
      if (mounted) context.go('/auth');
    } catch (error) {
      if (mounted) _showMessage(userErrorMessage(error));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('계정 관리')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/auth'),
            child: const Text('로그인'),
          ),
        ),
      );
    }
    if (!_initialized) {
      _initialized = true;
      _nicknameController.text = session.user.nickname;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('계정 관리')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person_outline, size: 36),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: session.user.email,
                readOnly: true,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _saveNickname,
                child: Text(_saving ? '저장 중...' : '닉네임 변경'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(authSessionProvider.notifier).logout();
                  if (context.mounted) context.go('/auth');
                },
                child: const Text('로그아웃'),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 12),
              Text('위험 영역', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: session.user.role == 'admin' ? null : _confirmDelete,
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(
                  session.user.role == 'admin' ? '관리자 계정은 탈퇴할 수 없습니다' : '회원 탈퇴',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
