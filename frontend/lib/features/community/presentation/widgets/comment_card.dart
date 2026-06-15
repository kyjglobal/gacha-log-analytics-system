import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/community_comment.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    this.canDelete = false,
    this.onDelete,
  });

  final CommunityComment comment;
  final bool canDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(comment.authorNickname.characters.first.toUpperCase()),
      ),
      title: Text(comment.authorNickname),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          comment.content,
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      trailing: canDelete
          ? IconButton(
              tooltip: '댓글 삭제',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            )
          : null,
    );
  }
}
