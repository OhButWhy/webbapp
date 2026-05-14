import 'dart:io';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final type = message['type'] as String?;
    
    if (type == 'user') {
      return _buildUserMessage(context, message['text'] as String?);
    } else if (type == 'user_image') {
      return _buildUserImageMessage(context, message);
    } else if (type == 'ai') {
      return _buildAIMessage(context, message);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildUserMessage(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFC47A8A),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: const Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserImageMessage(BuildContext context, Map<String, dynamic> message) {
    final imagePath = message['imagePath'] as String?;
    final text = message['text'] as String?;
    final fileExists = imagePath != null && File(imagePath).existsSync();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (text != null && text.isNotEmpty)
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47A8A),
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomRight: const Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          if (fileExists)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.pink,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context, Map<String, dynamic> message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.pink.shade300,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['title'] ?? 'Recommendation',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message['description'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSmallButton(Icons.add, 'Wardrobe'),
              const SizedBox(width: 8),
              _buildSmallButton(Icons.favorite_border, 'Like'),
              const SizedBox(width: 8),
              _buildSmallButton(Icons.close, 'Dislike'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: Colors.black87),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}
