import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/chat_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class ChatInfo extends StatefulWidget {
  const ChatInfo({super.key});

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> with WidgetsBindingObserver {
  final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    updateUserStatus(isOnline: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    updateUserStatus(isOnline: false);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      updateUserStatus(isOnline: true);
    } else if (state == AppLifecycleState.paused) {
      updateUserStatus(isOnline: false);
    }
    super.didChangeAppLifecycleState(state);
  }

  void updateUserStatus({required bool isOnline}) async {
    final userId = "";
    await firebaseFireStore.collection('chats').doc(userId).set({
      'state': isOnline ? "Online" : "Offline",
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage({
    required int? roomId,
    required int? senderId,
    required String senderType,
    required int? bid,
    required String message,
    required String media,
    required String mediaType,
  }) async {
    try {
      final messageRef = firebaseFireStore
          .collection('chats')
          .doc(roomId.toString())
          .collection('messages')
          .doc();

      await messageRef.set({
        'chatid': messageRef.id,
        'senderid': senderId,
        'sendertype': senderType,
        'bid': bid,
        'message': message,
        'media': media,
        'mediatype': mediaType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('FireStore error while sending message: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('Unexpected error while sending message: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  final List<ChatMessage> messages = [
    ChatMessage(
      text: "That was a good idea Nithyakumar",
      isMe: false,
      time: "09:36 AM",
    ),
    ChatMessage(
      text:
          "But I think we should consider the budget since we don't have much budget",
      isMe: true,
      time: "09:36 AM",
    ),
    ChatMessage(
      text: "I agree with this. We find another way",
      isMe: false,
      time: "09:38 AM",
    ),
    ChatMessage(
      imageUrl: "https://images.unsplash.com/photo-1521335629791-ce4aec67dd47",
      isMe: false,
      time: "02:46 PM",
    ),
    ChatMessage(
      text: "That's great bro. We go with this",
      isMe: true,
      time: "02:47 PM",
    ),
  ];

  bool isFirstInSequence(int index, List<ChatMessage> messages) {
    if (index == 0) return true;
    return messages[index].isMe != messages[index - 1].isMe;
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(AppIcons.chatLayer1P),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(AppIcons.chatLayer2P),
            ),

            Positioned.fill(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        height: 49,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.arrowBack,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                    title: HeaderTextBlack(
                      title: 'Profile Name',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: BodyTextColors(
                      title: 'Online',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: GenericColors.darkGreen,
                    ),
                    trailing: Icon(Icons.more_vert),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final showAvatar = isFirstInSequence(index, messages);
                      return ChatBubble(
                        message: messages[index],
                        showAvatar: showAvatar,
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: ChatTextFiled()),
          ],
        ),
      ),
    );
  }
}

class ChatTextFiled extends StatelessWidget {
  const ChatTextFiled({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: Themes.searchFieldDecoration(
                borderRadius: 30,
                blurRadius: 2,
              ),
              child: TextField(
                cursorColor: AppColors.primary,
                style: AppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ).textStyle,
                minLines: 1,
                maxLines: 5,
                expands: false,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Type here Something",
                  filled: true,
                  isDense: true,
                  hintStyle: AppTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: GenericColors.borderGrey,
                  ).textStyle,
                  counterText: '',
                  contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  fillColor: AppColors.scaffoldBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(AppIcons.galleryColorP, height: 20),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkText,
            ),
            clipBehavior: Clip.hardEdge,
            child: Center(
              child: Icon(Icons.send, size: 24, color: AppColors.whiteText),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.showAvatar,
  });

  final ChatMessage message;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: message.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isMe && showAvatar) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('${message.profile}'),
                ),
              ] else if (!message.isMe) ...[
                const SizedBox(width: 32),
              ],
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: bubbleRadius(message.isMe),
                  ),
                  child: message.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.imageUrl!,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      : BodyTextColors(
                          title: message.text!,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0XFF484848),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              if (message.isMe && showAvatar) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('${message.profile}'),
                ),
              ] else if (message.isMe) ...[
                const SizedBox(width: 32),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(
              right: message.isMe ? 32 : 0,
              left: message.isMe ? 0 : 32,
            ),
            child: BodyTextColors(
              title: message.time,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0XFFB3B5B7),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius bubbleRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: Radius.circular(isMe ? 12 : 0),
      topRight: Radius.circular(isMe ? 0 : 12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );
  }
}
