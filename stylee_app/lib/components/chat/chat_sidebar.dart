import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatSidebar extends StatelessWidget {
  final Stream<QuerySnapshot> chatsStream;
  final String? currentChatId;
  final VoidCallback onCreateNewChat;
  final Function(String) onOpenChat;
  final Function(String) onDeleteChat;

  const ChatSidebar({
    super.key,
    required this.chatsStream,
    this.currentChatId,
    required this.onCreateNewChat,
    required this.onOpenChat,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: onCreateNewChat,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Создать чат'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final chats = snapshot.data!.docs;
                
                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет чатов',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    final chatId = chats[index].id;
                    final isSelected = chatId == currentChatId;
                    
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.pink.shade50,
                      leading: const Icon(Icons.chat_bubble_outline, size: 20),
                      title: Text(
                        chat['title'] ?? 'Новый чат',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.grey.shade400,
                        onPressed: () => onDeleteChat(chatId),
                      ),
                      onTap: () => onOpenChat(chatId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
