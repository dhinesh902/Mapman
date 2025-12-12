import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/views/auth_screens/login.dart';
import 'package:mapman/views/auth_screens/onboard.dart';
import 'package:mapman/views/auth_screens/splash.dart';
import 'package:mapman/views/main_dashboard/home/saved_videos.dart';
import 'package:mapman/views/main_dashboard/main_dashboard.dart';
import 'package:mapman/views/main_dashboard/notification/notification_settings.dart';
import 'package:mapman/views/main_dashboard/notification/notifications.dart';
import 'package:mapman/views/main_dashboard/notification/viewed_videos.dart';
import 'package:mapman/views/main_dashboard/profile/chat/chat_info.dart';
import 'package:mapman/views/main_dashboard/profile/chat/chats.dart';
import 'package:mapman/views/main_dashboard/profile/edit_profile.dart';
import 'package:mapman/views/main_dashboard/profile/help_and_support.dart';
import 'package:mapman/views/main_dashboard/profile/add_shop_detail.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/enter_location.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/enter_your_location.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/register_shop_detail.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/shop_detail.dart';
import 'package:mapman/views/main_dashboard/video/replace_video.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/main_dashboard/video/upload_video.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.splashScreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/onboard_screen',
        name: AppRoutes.onboardScreen,
        builder: (context, state) => OnboardScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => Login(),
      ),
      GoRoute(
        path: '/main_dashboard',
        name: AppRoutes.mainDashboard,
        builder: (context, state) => MainDashboard(),
        routes: [
          GoRoute(
            path: '/notifications',
            name: AppRoutes.notifications,
            builder: (context, state) => Notifications(),
            routes: [
              GoRoute(
                path: '/notification_settings',
                name: AppRoutes.notificationSettings,
                builder: (context, state) => NotificationSettings(),
                routes: [
                  GoRoute(
                    path: '/viewed_videos',
                    name: AppRoutes.viewedVideos,
                    builder: (context, state) => ViewedVideos(),
                  ),
                  GoRoute(
                    path: '/viewed_videos_shop_detail',
                    name: AppRoutes.viewedVideosShopDetail,
                    builder: (context, state) => ShopDetail(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/saved_videos',
            name: AppRoutes.savedVideos,
            builder: (context, state) => SavedVideos(),
          ),
          GoRoute(
            path: '/upload_video',
            name: AppRoutes.uploadVideo,
            builder: (context, state) => UploadVideo(),
          ),
          GoRoute(
            path: '/replace_video',
            name: AppRoutes.replaceVideo,
            builder: (context, state) => ReplaceVideo(),
          ),
          GoRoute(
            path: '/single_video_screen',
            name: AppRoutes.singleVideoScreen,
            builder: (context, state) =>
                SingleVideoScreen(videoUrl: state.extra as String),
            routes: [
              GoRoute(
                path: '/shop_detail',
                name: AppRoutes.shopDetail,
                builder: (context, state) => ShopDetail(),
              ),
            ],
          ),
          GoRoute(
            path: '/edit_profile',
            name: AppRoutes.editProfile,
            builder: (context, state) => EditProfile(),
          ),
          GoRoute(
            path: '/chats',
            name: AppRoutes.chats,
            builder: (context, state) => Chats(),
            routes: [
              GoRoute(
                path: '/chat_info',
                name: AppRoutes.chatInfo,
                builder: (context, state) => ChatInfo(),
              ),
            ],
          ),
          GoRoute(
            path: '/help_and_support',
            name: AppRoutes.helpAndSupport,
            builder: (context, state) => HelpAndSupport(),
          ),
          GoRoute(
            path: '/add_shop_detail',
            name: AppRoutes.addShopDetail,
            builder: (context, state) => AddShopDetail(),
            routes: [
              GoRoute(
                path: '/register_shop_detail',
                name: AppRoutes.registerShopDetail,
                builder: (context, state) => RegisterShopDetail(),
                routes: [
                  GoRoute(
                    path: '/enter_location',
                    name: AppRoutes.enterLocation,
                    builder: (context, state) => EnterLocation(),
                    routes: [
                      GoRoute(
                        path: '/enter_your_location',
                        name: AppRoutes.enterYourLocation,
                        builder: (context, state) => EnterYourLocation(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
