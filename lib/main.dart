import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/place_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/firebase_options.dart';
import 'package:mapman/routes/router.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Flutter Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Local notification display
Future<void> showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel_id',
          'Default Channel',
          channelDescription: 'For showing order notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: 'notifications',
    );
  }
}

/// Initialization for local notifications
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint("Notification tapped: ${response.payload}");
      _handleNotificationNavigation(response.payload);
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  _handleNotificationNavigation(response.payload);
}

void _handleNotificationNavigation(String? payload) {
  if (payload == 'notifications') {
    AppRouter.router.go('/main_dashboard/notifications');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache
    ..maximumSize = 100
    ..maximumSizeBytes = 50 * 1024 * 1024;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPrefs = await SessionManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthController()),
        ChangeNotifierProvider.value(value: HomeController()),
        ChangeNotifierProvider.value(value: VideoController()),
        ChangeNotifierProvider.value(value: ProfileController()),
        ChangeNotifierProvider.value(value: PlaceController()),
      ],
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await initializeLocalNotifications();

    final firebaseMessaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        if (kDebugMode) print("User declined notifications");
      }
    }

    /// Background & foreground handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('App opened from notification: ${message.messageId}');
    });

    /// FCM token refresh
    firebaseMessaging.onTokenRefresh.listen((fcmToken) async {
      await sharedPrefs.setString(Keys.fcmToken, fcmToken);
      await AuthController().addFcmToken();
    });

    /// Initial token fetch (iOS retry after small delay)
    if (Platform.isIOS) {
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          final token = await firebaseMessaging.getToken();
          if (token != null) {
            await sharedPrefs.setString(Keys.fcmToken, token);
            await AuthController().addFcmToken();
          }
        } catch (e) {
          if (kDebugMode) print("TOKEN FAILED: $e");
        }
      });
    } else {
      try {
        final token = await firebaseMessaging.getToken();
        if (token != null) {
          await sharedPrefs.setString(Keys.fcmToken, token);
          await AuthController().addFcmToken();
        }
      } catch (e) {
        if (kDebugMode) print("Error getting token: $e");
      }
    }

    /// iOS foreground notification display
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  });

  const fatalError = true;

  /// Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      /// If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);

      /// ignore: dead_code
    } else {
      /// If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };

  /// Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      /// If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      /// ignore: dead_code
    } else {
      /// If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mapman',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
