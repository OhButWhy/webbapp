import 'dart:io';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final String? selectedImagePath;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSendMessage;
  final Function(String) onSubmitted;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isLoading,
    this.selectedImagePath,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSendMessage,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (selectedImagePath != null && File(selectedImagePath!).existsSync())
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(File(selectedImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Фото прикреплено',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemoveImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade500,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Напишите сообщение...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF5E6E8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isLoading ? null : onSendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
