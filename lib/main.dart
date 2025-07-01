import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vacation_homework_app/screens/diary_detail_screen.dart';
import 'package:vacation_homework_app/screens/diary_write_screen.dart';
import 'package:vacation_homework_app/screens/home_screen.dart';
import 'package:vacation_homework_app/screens/login_screen.dart';
import 'package:vacation_homework_app/screens/register_screen.dart';
import 'package:vacation_homework_app/screens/settings_screen.dart';
import 'package:vacation_homework_app/services/api_client.dart';
import 'package:vacation_homework_app/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void setupNotificationChannel() {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 [BG] 백그라운드 메시지: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko');
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupNotificationChannel();
  await initFCM();
  setupFCMHandlers();
  ApiClient.setupInterceptor();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final isLoggedIn = token != null && token.isNotEmpty;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 914),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (_, __) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: '방학숙제 일기장',
          theme: ThemeData(
            fontFamily: 'Pretendard',
            scaffoldBackgroundColor: const Color.fromARGB(248, 252, 252, 252),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(248, 249, 249, 249),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Color.fromARGB(255, 61, 61, 61),
            ),
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 68, 64, 64),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          builder: (context, child) {
            return ColoredBox(
              color: const Color.fromARGB(248, 252, 252, 252),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: false,
                child: child!,
              ),
            );
          },
          initialRoute: isLoggedIn ? '/home' : '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/write':
              return MaterialPageRoute(builder: (_) => const DiaryWriteScreen());
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            case '/detail':
              final homeworkSeq = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => DiaryDetailScreen(homeworkSeq: homeworkSeq),
              );
            default:
              return null;
          }
        },

        );
      },
    );
  }
}

Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    debugPrint('📱 FCM Token: $token');
  } else {
    debugPrint('🚫 푸시 권한이 거부되었거나 아직 설정되지 않았습니다.');
  }

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      debugPrint('🟢 [onDidReceiveNotificationResponse] payload: $payload');
      if (payload != null) {
        Future.microtask(() {
          navigatorKey.currentState
              ?.pushNamed('/detail', arguments: payload);
        });
      }
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📩 [포그라운드 수신] ${message.notification?.title}');

    if (message.notification != null) {
      final title = message.notification?.title ?? message.data['title'] ?? '알림';
      final body = message.notification?.body ?? message.data['body'] ?? '내용 없음';
      final homeworkSeq = message.data['homeworkSeq']?.toString();

      debugPrint('📩 [데이터 : ] $title, $body, $homeworkSeq');

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: '중요 알림 채널',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: homeworkSeq,
      );
    }
  });
}

void setupFCMHandlers() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final homeworkSeq = message.data['homeworkSeq']?.toString();
    debugPrint('🟡 [onMessageOpenedApp] homeworkSeq: $homeworkSeq');
    if (homeworkSeq != null) {
      navigatorKey.currentState
          ?.pushNamed('/detail', arguments: homeworkSeq);
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    final homeworkSeq = message?.data['homeworkSeq']?.toString();
    debugPrint('🔵 [getInitialMessage] homeworkSeq: $homeworkSeq');
    if (homeworkSeq != null) {
      navigatorKey.currentState
          ?.pushNamed('/detail', arguments: homeworkSeq);
    }
  });
}
