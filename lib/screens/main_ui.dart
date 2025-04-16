import 'package:chatter_bridge/screens/tabs/bookmark_tab.dart';
import 'package:chatter_bridge/screens/tabs/home_tab.dart';
import 'package:chatter_bridge/screens/tabs/language_tab.dart';
import 'package:chatter_bridge/screens/tabs/setting_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const BookmarkTab(),
    LanguageTab(),
    const SettingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      backgroundColor: Colors.amber[200],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_add_outlined),
            selectedIcon: Icon(Icons.bookmark_add),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.language_outlined),
            selectedIcon: Icon(Icons.language_rounded),
            label: 'Language',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        indicatorColor: Colors.amber[300],
        height: 65,
      ),
    );
  }
}
