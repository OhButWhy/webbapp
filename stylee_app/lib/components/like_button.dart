import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onTap;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            likeCount > 0 ? likeCount.toString() : '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}