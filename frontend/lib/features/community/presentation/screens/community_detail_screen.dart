import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/network/error_message.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../providers/community_providers.dart';
import '../widgets/comment_card.dart';
import '../widgets/community_category_chip.dart';
import '../widgets/probability_result_card.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final _commentController = TextEditingController();
  bool _commentSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (ref.read(authSessionProvider).value == null) {
      context.push('/auth');
      return;
    }
    try {
      await ref.read(communityRepositoryProvider).toggleLike(widget.postId);
      ref.invalidate(communityPostProvider(widget.postId));
      ref.invalidate(communityPostsProvider);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _createComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    if (ref.read(authSessionProvider).value == null) {
      context.push('/auth');
      return;
    }
    setState(() => _commentSubmitting = true);
    try {
      await ref
          .read(communityRepositoryProvider)
          .createComment(widget.postId, content);
      _commentController.clear();
      ref.invalidate(communityCommentsProvider(widget.postId));
      ref.invalidate(communityPostProvider(widget.postId));
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _commentSubmitting = false);
    }
  }

  Future<void> _deletePost() async {
    try {
      await ref.read(communityRepositoryProvider).deletePost(widget.postId);
      ref.invalidate(communityPostsProvider);
      if (mounted) context.go('/community');
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userErrorMessage(error))));
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(communityPostProvider(widget.postId));
    final commentsState = ref.watch(communityCommentsProvider(widget.postId));
    final currentUser = ref.watch(authSessionProvider).value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
        actions: [
          postState.maybeWhen(
            data: (post) =>
                currentUser != null &&
                    (currentUser.id == post.userId ||
                        currentUser.role == 'admin')
                ? Row(
                    children: [
                      IconButton(
                        tooltip: '수정',
                        onPressed: () =>
                            context.push('/community/posts/${post.id}/edit'),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: '삭제',
                        onPressed: _deletePost,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: postState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(userErrorMessage(error), textAlign: TextAlign.center),
        ),
        data: (post) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CommunityCategoryChip(category: post.category),
            const SizedBox(height: 14),
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${post.authorNickname} · 조회 ${post.viewCount}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 22),
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl!,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (post.certification != null) ...[
              ProbabilityResultCard(certification: post.certification!),
              const SizedBox(height: 18),
            ],
            SelectableText(post.content),
            const SizedBox(height: 22),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _toggleLike,
                  icon: const Icon(Icons.favorite_border),
                  label: Text('좋아요 ${post.likeCount}'),
                ),
                const SizedBox(width: 12),
                Text('댓글 ${post.commentCount}'),
              ],
            ),
            const Divider(height: 42),
            Text('댓글', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: '댓글을 입력하세요.'),
                    onSubmitted: (_) => _createComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _commentSubmitting ? null : _createComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 12),
            commentsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(userErrorMessage(error)),
              data: (comments) => Column(
                children: comments
                    .map(
                      (comment) => CommentCard(
                        comment: comment,
                        canDelete:
                            currentUser != null &&
                            (currentUser.id == comment.userId ||
                                currentUser.role == 'admin'),
                        onDelete: () async {
                          try {
                            await ref
                                .read(communityRepositoryProvider)
                                .deleteComment(comment.id);
                            ref.invalidate(
                              communityCommentsProvider(widget.postId),
                            );
                            ref.invalidate(
                              communityPostProvider(widget.postId),
                            );
                          } catch (error) {
                            if (mounted) _showError(error);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
