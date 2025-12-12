import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String userId;
  final String chatId;
  final List<String> users;
  final String lastMessage;
  final int lastMessageTime;
  final Map<String, dynamic>? userInfo;

  ChatModel({
    required this.userId,
    required this.chatId,
    required this.users,
    required this.lastMessage,
    required this.lastMessageTime,
    this.userInfo,
  });

  factory ChatModel.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatModel(
      chatId: doc.id,
      userId: data['userid'],
      users: List<String>.from(data['users'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] ?? 0,
      userInfo: data['userInfo'] != null
          ? Map<String, dynamic>.from(data['userInfo'])
          : null,
    );
  }

  String getOtherUserId(String currentUserId) {
    return users.firstWhere((uid) => uid != currentUserId);
  }

  String getOtherUserName(String currentUserId) {
    if (userInfo == null) return "Unknown";

    final otherId = getOtherUserId(currentUserId);
    return userInfo![otherId]?['name'] ?? "Unknown";
  }

  String getOtherUserImage(String currentUserId) {
    if (userInfo == null) return "";

    final otherId = getOtherUserId(currentUserId);
    return userInfo![otherId]?['image'] ?? "";
  }
}
