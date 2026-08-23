import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat/chat_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/chat_header.dart';
import '../services/user_service.dart';
import 'package:intl/intl.dart';
import 'user_profile_page.dart';
import '../services/favorite_service.dart';
import '../generated/app_localizations.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FavoriteService _favoriteService = FavoriteService();

  Future<void> sendMessage() async {
    final l10n = AppLocalizations.of(context)!;

    if (_controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final blocked = await _userService.isBlocked(
      currentUserId: user.uid,
      otherUserId: widget.receiverId,
    );

    if (blocked) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotMessageUser),
        ),
      );
      return;
    }
    final message = MessageModel(
      id: '',
      senderId: user.uid,
      receiverId: widget.receiverId,
      message: _controller.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        message: message,
      );
      _controller.clear();
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderilemedi: $exception')),
      );
    }
  }

  Future<void> sendImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image == null) return;

    final imageUrl = await _chatService.uploadChatImage(
      File(image.path),
    );

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      receiverId: widget.receiverId,
      message: '',
      type: 'image',
      fileUrl: imageUrl,
      fileName: image.name,
      createdAt: DateTime.now(),
    );

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        message: message,
      );
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf gönderilemedi: $exception')),
      );
    }
  }

  void _showAttachmentSheet() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _attachmentItem(
                  Icons.photo,
                  Colors.purple,
                  l10n.gallery,
                      () async {
                    Navigator.pop(context);
                    await sendImage();
                  },
                ),
                _attachmentItem(
                  Icons.camera_alt,
                  Colors.red,
                  l10n.camera,
                      () {},
                ),
                _attachmentItem(
                  Icons.insert_drive_file,
                  Colors.orange,
                  l10n.document,
                      () {},
                ),
                _attachmentItem(
                  Icons.location_on,
                  Colors.green,
                  l10n.location,
                      () {},
                ),
                _attachmentItem(
                  Icons.videocam,
                  Colors.blue,
                  l10n.video,
                      () {},
                ),
                _attachmentItem(
                  Icons.mic,
                  Colors.teal,
                  l10n.audio,
                      () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentItem(
      IconData icon,
      Color color,
      String title,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      _userService.setOnlineStatus(uid, true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    if (state == AppLifecycleState.resumed) {
      _userService.setOnlineStatus(uid, true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _userService.setOnlineStatus(uid, false);
    }
  }

  String _getStatusText(bool isOnline, DateTime? lastSeen) {
    final l10n = AppLocalizations.of(context)!;

    if (isOnline) return l10n.activeNow;

    if (lastSeen == null) return l10n.offline;

    final now = DateTime.now();

    if (lastSeen.year == now.year &&
        lastSeen.month == now.month &&
        lastSeen.day == now.day) {
      return l10n.lastSeenToday(DateFormat('HH:mm').format(lastSeen));
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (lastSeen.year == yesterday.year &&
        lastSeen.month == yesterday.month &&
        lastSeen.day == yesterday.day) {
      return l10n.lastSeenYesterday(DateFormat('HH:mm').format(lastSeen));
    }

    return l10n.lastSeenDate(DateFormat('dd.MM.yyyy HH:mm').format(lastSeen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatService.markMessagesAsDelivered(
          chatId: widget.chatId,
          currentUserId: currentUser.uid,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          _chatService.markMessagesAsSeen(
            chatId: widget.chatId,
            currentUserId: currentUser.uid,
          );
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [

          StreamBuilder(
            stream: _userService.streamUser(widget.receiverId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return StreamBuilder<bool>(
                  stream: _userService.isBlockedStream(
                    currentUserId: currentUser!.uid,
                    blockedUserId: widget.receiverId,
                  ),
                  builder: (context, blockedSnapshot) {
                    final blocked = blockedSnapshot.data ?? false;

                    return ChatHeader(
                      name: widget.receiverName,
                      profilePhoto: "",
                      isOnline: false,
                      lastSeen: null,
                      statusText: l10n.offline,
                      isBlocked: false,
                      onBack: () => Navigator.pop(context),
                      onMenu: (value) async {
                        switch (value) {
                          case "favorite":
                            await _favoriteService.toggleFavorite(widget.receiverId);

                            final isFavorite =
                            await _favoriteService.isFavorite(widget.receiverId);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? l10n.favoriteAdded(widget.receiverName)
                                        : l10n.favoriteRemoved(widget.receiverName),
                                  ),
                                ),
                              );
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.favoriteAdded(widget.receiverName)),
                                ),
                              );
                            }
                            break;
                          case "profile":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfilePage(
                                  userId: widget.receiverId,
                                ),
                              ),
                            );
                            break;

                          case "clear":
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.clearChat),
                                content: Text(
                                    l10n.clearChatConfirmation,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      l10n.cancel,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await _chatService.clearChat(
                                        chatId: widget.chatId,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                           SnackBar(
                                            content: Text(l10n.chatCleared),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(l10n.clear),
                                  ),
                                ],
                              ),
                            );
                            break;

                          case "delete":
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.deleteChat),
                                content: Text(
                                    l10n.deleteChatConfirmation,
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await _chatService.deleteChat(
                                        chatId: widget.chatId,
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.chatDeleted),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text("Sil"),
                                  ),
                                ],
                              ),
                            );
                            break;

                          case "block":
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.blockUser),
                                content: Text(
                                  l10n.blockConfirmation(widget.receiverName),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await _userService.blockUser(
                                        currentUserId: currentUser!.uid,
                                        blockedUserId: widget.receiverId,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.userBlocked(widget.receiverName)),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(l10n.block),
                                  ),
                                ],
                              ),
                            );
                            break;
                        }
                      },
                    );
                  },
                );
              }


              final user = snapshot.data!;

              return ChatHeader(
                name: "${user.firstName} ${user.lastName}",
                profilePhoto: user.profilePhoto,
                isOnline: user.isOnline,
                lastSeen: user.lastSeen,
                statusText: _getStatusText(
                  user.isOnline,
                  user.lastSeen,
                ),
                isBlocked: false,
                onBack: () => Navigator.pop(context),
                onMenu: (value) async {
                  switch (value) {
                    case "favorite":
                      await _favoriteService.toggleFavorite(widget.receiverId);

                      final isFavorite =
                      await _favoriteService.isFavorite(widget.receiverId);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? "${widget.receiverName} favorilere eklendi."
                                  : "${widget.receiverName} favorilerden çıkarıldı.",
                            ),
                          ),
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.favoriteAdded(widget.receiverName)),
                          ),
                        );
                      }
                      break;
                    case "profile":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfilePage(
                            userId: widget.receiverId,
                          ),
                        ),
                      );
                      break;

                    case "clear":
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l10n.clearChat),
                          content: Text(
                              l10n.clearChatConfirmation,
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                Navigator.pop(context);

                                await _chatService.clearChat(
                                  chatId: widget.chatId,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.chatCleared),
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.clear),
                            ),
                          ],
                        ),
                      );
                      break;

                    case "delete":
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l10n.deleteChat),
                          content: Text(
                              l10n.deleteChatConfirmation,
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                Navigator.pop(context);

                                await _chatService.deleteChat(
                                  chatId: widget.chatId,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                      content: Text(l10n.chatDeleted),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Sil"),
                            ),
                          ],
                        ),
                      );
                      break;
                    case "block":
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l10n.blockUser),
                          content: Text(
                            "${widget.receiverName} adlı kullanıcıyı engellemek istiyor musunuz?\n\n"
                                "• Artık size mesaj gönderemeyecek.\n"
                                "• Siz de ona mesaj gönderemeyeceksiniz.",
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                Navigator.pop(context);

                                await _userService.blockUser(
                                  currentUserId: currentUser!.uid,
                                  blockedUserId: widget.receiverId,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.userBlocked(widget.receiverName)),
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.block),
                            ),
                          ],
                        ),
                      );
                      break;
                  }
                },
              );
            },
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                image: DecorationImage(
                  image: AssetImage("assets/images/chat_bg.png"),
                  fit: BoxFit.cover,
                  opacity: 0.60,
                ),
              ),
              child: Column(

                children: [
                  Expanded(
                    child: StreamBuilder<List<MessageModel>>(
                      stream: _chatService.getMessages(
                        chatId: widget.chatId,
                        userId: currentUser!.uid,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data!;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });

                        if (messages.isEmpty) {
                          return Center(
                            child: Text(l10n.noMessages),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg.senderId == currentUser?.uid;

                            return ChatBubble(
                              msg: msg,
                              isMe: isMe,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  FutureBuilder<bool>(
                    future: _userService.isBlocked(
                      currentUserId: currentUser!.uid,
                      otherUserId: widget.receiverId,
                    ),
                    builder: (context, snapshot) {
                      final blocked = snapshot.data ?? false;

                      if (blocked) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.red,
                          child: Text(
                            l10n.cannotMessageBlockedUser,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return ChatInput(
                        controller: _controller,
                        onSend: sendMessage,
                        onAttachment: _showAttachmentSheet,
                        onCamera: () {},
                        onMic: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      _userService.setOnlineStatus(uid, false);
    }

    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
