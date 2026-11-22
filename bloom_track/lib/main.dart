import 'package:bloom_track/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'auth/auth.dart';
import 'home.dart';
import 'session/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.instance.load();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Widget startScreen = const AuthPage();

    if (UserSession.instance.isLoggedIn) {
      startScreen = const HomePage();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BloomTrack',
      theme: ThemeData.light(),
      home: startScreen,
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
