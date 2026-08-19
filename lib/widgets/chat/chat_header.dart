import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final String name;
  final String profilePhoto;
  final bool isOnline;
  final DateTime? lastSeen;
  final VoidCallback onBack;
  final Future<void> Function(String) onMenu;
  final String statusText;
  final bool isBlocked;

  const ChatHeader({
    super.key,
    required this.name,
    required this.profilePhoto,
    required this.isOnline,
    required this.lastSeen,
    required this.statusText,
    required this.onBack,
    required this.onMenu,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [

              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),

              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xffe9ecef),
                backgroundImage:
                profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
                child: profilePhoto.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.grey,
                )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: [

                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          statusText,
                          style: TextStyle(
                            color: isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: "Menü",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                onSelected: (value) async {
                  await onMenu(value);
                },
                itemBuilder: (context) =>  [
                  PopupMenuItem<String>(
                    value: "profile",
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 10),
                        Text("Profili Gör"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "favorite",
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Favoriye Ekle"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "clear",
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services_outlined),
                        SizedBox(width: 10),
                        Text("Sohbeti Temizle"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Sohbeti Sil"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "block",
                    child: Row(
                      children: [
                        Icon(
                          isBlocked ? Icons.lock_open : Icons.block,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isBlocked ? "Engeli Kaldır" : "Engelle",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}