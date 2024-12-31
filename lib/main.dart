import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/core/theme/theme_helper.dart';
import 'package:burntech/view/admin_view/admin_home/admin_home_page.dart';
import 'package:burntech/view/admin_view/admin_nav/admin_bottom_navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notification_service/notification_service.dart';
import 'firebase_options.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'view/user_view/bottom_nav_bar/bottom_nav_bar.dart';
import 'view/user_view/onboarding_screen/onboarding_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(ProviderScope(child: const MyApp()));
}

late Size mq;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: globalMessengerKey,
      title: 'Flutter Demo',
      theme: theme,
      home: getHomeScreen(),
    );
  }
}

Widget getHomeScreen() {
  if (FirebaseConstants.auth.currentUser?.email?.toLowerCase() ==
      "abhishek@gmail.com") {
    return AdminBottomBar();
  } else if (FirebaseConstants.auth.currentUser == null) {
    return OnboardingScreen();
  }

  return BottomNavBar();
}
