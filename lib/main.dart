import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel_id',
          'Default Channel',
          channelDescription: 'For showing order notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }
}

/// Initialization for local notifications
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
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
  if (payload == null) return;

  if (payload == 'notifications') {
    AppRouter.router.go('/main_dashboard/notifications');
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
  await showLocalNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 500));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPrefs = await SessionManager.initialize();
  final firebaseMessaging = FirebaseMessaging.instance;

  /// IOS: request notification permissions
  if (Platform.isIOS) {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("User declined notifications");
    }
  }

  /// Background & foreground handlers
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    debugPrint('Foreground message: ${message.notification}');
    if (message.notification != null) {
      showLocalNotification(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('App opened from notification: ${message.messageId}');
  });

  /// Listen for token updates
  firebaseMessaging.onTokenRefresh.listen((fcmToken) async {
    print("FCM token available: $fcmToken");
    await sharedPrefs.setString(Keys.fcmToken, fcmToken);
    await AuthController().addFcmToken();
  });

  /// Retry fetching token after a short delay for iOS
  if (Platform.isIOS) {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        String? initialToken = await firebaseMessaging.getToken();
        if (initialToken != null) {
          print("DEEPAK:Initial FCM token: $initialToken");
          await sharedPrefs.setString(Keys.fcmToken, initialToken);
          await AuthController().addFcmToken();
        }
      } catch (e) {
        print("DEEPAK TOKEN FAILED: $e");
      }
    });
  } else {
    /// Android: get token immediately
    try {
      String? initialToken = await firebaseMessaging.getToken();
      if (initialToken != null) {
        await sharedPrefs.setString(Keys.fcmToken, initialToken);
        await AuthController().addFcmToken();
      }
    } catch (e) {
      print("Error getting token: $e");
    }
  }

  /// IOS foreground notification display
  await firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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
