import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    updateUserStatus(isOnline: true);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    updateUserStatus(isOnline: false);
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
