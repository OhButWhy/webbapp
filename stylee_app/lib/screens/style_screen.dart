import 'package:flutter/material.dart';

/// Экран стайлинга - место для подбора образов и стилей
class StyleScreen extends StatelessWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Style',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ваш персональный стилист',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Cards for different style features
              _buildStyleCard(
                context,
                icon: Icons.auto_awesome_outlined,
                title: 'AI Подбор образов',
                description: 'Получайте рекомендации от AI на основе вашего стиля и размеров',
                color: const Color(0xFFE91E63),
                iconColor: Colors.white,
              ),
              const SizedBox(height: 16),
              _buildStyleCard(
                context,
                icon: Icons.palette_outlined,
                title: 'Подбор цветов',
                description: 'Узнайте, какие цвета лучше всего вам идут',
                color: const Color(0xFF9C27B0),
                iconColor: Colors.white,
              ),
              const SizedBox(height: 16),
              _buildStyleCard(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Витрина',
                description: 'Магазины и бренды, подходящие вам',
                color: const Color(0xFF00BCD4),
                iconColor: Colors.white,
              ),
              const SizedBox(height: 16),
              _buildStyleCard(
                context,
                icon: Icons.camera_alt_outlined,
                title: 'Виртуальная примерка',
                description: 'Попробуйте одежду виртуально',
                color: const Color(0xFF4CAF50),
                iconColor: Colors.white,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Перейти к соответствующей странице
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
