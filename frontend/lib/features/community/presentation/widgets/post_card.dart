import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/community_post.dart';
import 'community_category_chip.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onTap});

  final CommunityPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CommunityCategoryChip(category: post.category),
                  if (post.certification != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.success,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    post.authorNickname,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 17),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}'),
                  const SizedBox(width: 14),
                  const Icon(Icons.chat_bubble_outline, size: 17),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}'),
                  const SizedBox(width: 14),
                  const Icon(Icons.visibility_outlined, size: 17),
                  const SizedBox(width: 4),
                  Text('${post.viewCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
