import 'package:flutter/material.dart';

class MarketplaceSearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const MarketplaceSearchButton({
    super.key,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'M',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            height: 1,
          ),
        ),
      ),
    );
  }
}
