import 'package:bloom_track/bottom/bottom_journal.dart';
import 'package:bloom_track/bottom/bottom_status.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../session/user_session.dart';
import 'auth/auth.dart';
import 'bottom/bottom_profile.dart';
import 'bottom/bottom_plants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final screens = const [PlantsPage(), StatusPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(backgroundColor: Color(0xFFFFFDD0), elevation: 0),
      body: screens.elementAt(index),
      bottomNavigationBar: SalomonBottomBar(
        selectedItemColor: Color(0xFFA8D030),
        unselectedItemColor: Color(0xFFA89A8A),

        onTap: (p0) {
          setState(() {
            index = p0;
          });
        },

        currentIndex: index,

        items: [
          SalomonBottomBarItem(icon: Icon(Icons.eco), title: Text('Растения')),
          SalomonBottomBarItem(
            icon: Icon(Icons.analytics_outlined),
            title: Text('Статус'),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Профиль'),
          ),
        ],
      ),
    );
  }
}
