import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(authSessionProvider.notifier);
    if (_isSignUp) {
      await notifier.signUp(
        email: _emailController.text.trim(),
        nickname: _nicknameController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
    if (!mounted) return;
    final session = ref.read(authSessionProvider).value;
    if (session != null) context.go('/community');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authSessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? '회원가입' : '로그인')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: '닉네임'),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                child: Text(
                  auth.isLoading ? '처리 중...' : (_isSignUp ? '가입하기' : '로그인'),
                ),
              ),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? '기존 계정으로 로그인' : '새 계정 만들기'),
              ),
              if (auth.hasError)
                Text(
                  '요청을 처리하지 못했습니다: ${auth.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
