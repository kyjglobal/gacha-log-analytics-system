import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gacha/domain/gacha_models.dart';
import '../../../gacha/presentation/gacha_providers.dart';
import '../providers/community_providers.dart';

class ProbabilityCertificationScreen extends ConsumerStatefulWidget {
  const ProbabilityCertificationScreen({
    super.key,
    required this.gachaResultId,
  });

  final int gachaResultId;

  @override
  ConsumerState<ProbabilityCertificationScreen> createState() =>
      _ProbabilityCertificationScreenState();
}

class _ProbabilityCertificationScreenState
    extends ConsumerState<ProbabilityCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController();
  bool _submitting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final post = await ref
          .read(communityRepositoryProvider)
          .createCertification(
            gachaResultId: widget.gachaResultId,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            imageUrl: _imageController.text.trim().isEmpty
                ? null
                : _imageController.text.trim(),
          );
      ref.invalidate(communityPostsProvider);
      if (mounted) context.go('/community/posts/${post.id}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(gachaHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('확률 인증 게시글')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('가챠 결과를 불러오지 못했습니다.\n$error')),
        data: (page) {
          final selection = _findResult(page);
          if (selection == null) {
            return const Center(child: Text('인증할 가챠 결과를 찾을 수 없습니다.'));
          }
          final (draw, result) = selection;
          if (!_initialized) {
            _initialized = true;
            _titleController.text = '${result.itemName} 획득 확률 인증';
            _contentController.text =
                '${draw.bannerName}에서 ${result.itemName}을 획득했습니다.';
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified),
                    title: Text(result.itemName),
                    subtitle: Text(
                      '${result.rarity} · 공식 확률 '
                      '${(result.officialProbability * 100).toStringAsFixed(2)}% '
                      '· ${draw.drawCount}회 소환',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                  validator: (value) => value == null || value.trim().length < 2
                      ? '제목을 입력하세요.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  minLines: 6,
                  maxLines: 14,
                  decoration: const InputDecoration(labelText: '내용'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '내용을 입력하세요.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: '스크린샷 URL'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.verified),
                  label: Text(_submitting ? '등록 중...' : '인증 게시글 등록'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  (GachaDraw, GachaResultItem)? _findResult(GachaHistoryPage page) {
    for (final draw in page.items) {
      for (final result in draw.results) {
        if (result.id == widget.gachaResultId) return (draw, result);
      }
    }
    return null;
  }
}
