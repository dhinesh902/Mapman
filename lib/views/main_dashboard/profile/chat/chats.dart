import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/chat_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  Stream<List<ChatModel>> fetchUserChatList({required String userId}) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFireStore(doc)).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: 'Chats',
          action: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(AppIcons.chatsP, height: 30, width: 30),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 15),
            CustomSearchField(
              controller: TextEditingController(),
              hintText: 'Search by Profile Name',
              clearOnTap: () {},
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return ChatListTile(
                    onTap: () {
                      context.pushNamed(AppRoutes.chatInfo);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 76,
        margin: EdgeInsets.only(bottom: 10, right: 10, left: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadiusGeometry.circular(4),
        ),
        child: ListTile(
          leading: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.hardEdge,
            child: CustomNetworkImage(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNbkECXtEG_6-RV7CSNgNoYUGZE-JCliYm9g&s',
            ),
          ),
          title: HeaderTextBlack(
            title: 'Profile Name',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: BodyTextHint(
              title: 'Thats good idea,we can proceed..',
              fontSize: 12,
              fontWeight: FontWeight.w300,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            children: [
              BodyTextHint(
                title: '9.24 Am',
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: GenericColors.darkRed,
                  shape: BoxShape.circle,
                ),
                child: BodyTextColors(
                  title: '4+',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppColors.whiteText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
