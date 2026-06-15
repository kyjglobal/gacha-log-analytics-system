import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/network/error_message.dart';
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
    if (session != null) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authSessionProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final introduction = const _IntroductionPanel();
            final form = _AuthForm(
              isSignUp: _isSignUp,
              auth: auth,
              emailController: _emailController,
              nicknameController: _nicknameController,
              passwordController: _passwordController,
              onSubmit: _submit,
              onToggleMode: () => setState(() {
                _isSignUp = !_isSignUp;
              }),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 56 : 20,
                vertical: isWide ? 48 : 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isWide ? 96 : 48),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(flex: 6, child: introduction),
                              const SizedBox(width: 56),
                              Expanded(flex: 4, child: form),
                            ],
                          )
                        : Column(
                            children: [
                              introduction,
                              const SizedBox(height: 32),
                              form,
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IntroductionPanel extends StatelessWidget {
  const _IntroductionPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            _BrandMark(),
            SizedBox(width: 14),
            Text(
              '아스트라 기록 보관소',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 42),
        Text(
          '가챠 기록을 모으고,\n확률을 데이터로 확인하세요.',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 38,
            height: 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        Text(
          '가챠 결과와 인벤토리를 안전하게 관리하고 공식 확률과 실제 획득 확률을 '
          '비교할 수 있는 통계 분석 시스템입니다.',
          style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.7),
        ),
        SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FeatureChip(icon: Icons.auto_awesome, label: '가챠 결과 기록'),
            _FeatureChip(icon: Icons.inventory_2_outlined, label: '인벤토리 관리'),
            _FeatureChip(icon: Icons.query_stats, label: '확률 통계 분석'),
            _FeatureChip(icon: Icons.forum_outlined, label: '확률 인증 커뮤니티'),
          ],
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.isSignUp,
    required this.auth,
    required this.emailController,
    required this.nicknameController,
    required this.passwordController,
    required this.onSubmit,
    required this.onToggleMode,
  });

  final bool isSignUp;
  final AsyncValue<Object?> auth;
  final TextEditingController emailController;
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .24),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isSignUp ? '새 계정 만들기' : '다시 만나서 반갑습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            isSignUp
                ? '계정을 만들고 나만의 가챠 기록을 시작하세요.'
                : '로그인하여 저장된 인벤토리와 확률 통계를 확인하세요.',
          ),
          const SizedBox(height: 26),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: '이메일',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          if (isSignUp) ...[
            const SizedBox(height: 14),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) {
              if (!auth.isLoading) onSubmit();
            },
            decoration: const InputDecoration(
              labelText: '비밀번호',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: auth.isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              auth.isLoading ? '처리 중...' : (isSignUp ? '회원가입' : '로그인'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: auth.isLoading ? null : onToggleMode,
            child: Text(isSignUp ? '이미 계정이 있나요? 로그인' : '처음이신가요? 새 계정 만들기'),
          ),
          if (auth.hasError) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                userErrorMessage(auth.error),
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.auto_awesome),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
