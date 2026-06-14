import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/auth_providers.dart';
import '../../domain/community_category.dart';
import '../providers/community_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.postId});

  final int? postId;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController();
  CommunityCategory _category = CommunityCategory.free;
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
    if (ref.read(authSessionProvider).value == null) {
      context.push('/auth');
      return;
    }
    setState(() => _submitting = true);
    try {
      final repository = ref.read(communityRepositoryProvider);
      final post = widget.postId == null
          ? await repository.createPost(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              category: _category,
              imageUrl: _imageController.text.trim().isEmpty
                  ? null
                  : _imageController.text.trim(),
            )
          : await repository.updatePost(
              postId: widget.postId!,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              category: _category,
              imageUrl: _imageController.text.trim().isEmpty
                  ? null
                  : _imageController.text.trim(),
            );
      ref.invalidate(communityPostsProvider);
      ref.invalidate(communityPostProvider(post.id));
      if (mounted) context.go('/community/posts/${post.id}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postId != null && !_initialized) {
      final postState = ref.watch(communityPostProvider(widget.postId!));
      postState.whenData((post) {
        if (_initialized) return;
        _initialized = true;
        _titleController.text = post.title;
        _contentController.text = post.content;
        _imageController.text = post.imageUrl ?? '';
        _category = post.category;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.postId == null ? '게시글 작성' : '게시글 수정')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<CommunityCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: '카테고리'),
              items: CommunityCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
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
              minLines: 8,
              maxLines: 18,
              decoration: const InputDecoration(labelText: '내용'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '내용을 입력하세요.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: '이미지 URL',
                helperText: '파일 업로드는 확률 인증 단계에서 추가합니다.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '저장 중...' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}
