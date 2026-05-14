import 'package:flutter/material.dart';

class WardrobeHeader extends StatelessWidget {
  final bool isEditingSections;
  final VoidCallback onToggleEditing;
  final VoidCallback onBack;

  const WardrobeHeader({
    super.key,
    required this.isEditingSections,
    required this.onToggleEditing,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
          ),
          Column(
            children: [
              const Text(
                'My Wardrobe',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  letterSpacing: 0.3,
                ),
              ),
              if (isEditingSections)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => AnimatedOpacity(
                    opacity: value,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A5B7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Режим редактирования',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD4A5B7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditingSections)
                GestureDetector(
                  onTap: onToggleEditing,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF333333)),
                  ),
                )
              else
                GestureDetector(
                  onTap: onToggleEditing,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A5B7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A5B7).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, size: 18, color: Colors.white),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.tune_outlined, size: 20, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
