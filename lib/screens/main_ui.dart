import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:chatter_bridge/screens/tabs/bookmark_tab.dart';
import 'package:chatter_bridge/screens/tabs/home_tab.dart';
//import 'package:chatter_bridge/screens/tabs/language_tab.dart';
import 'package:chatter_bridge/screens/tabs/setting_tab.dart';

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
    //LanguageTab(),
    const SettingTab(),
  ];

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _checkInitialConnection);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.isNotEmpty) {
        _handleConnectivity(results.first);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _handleConnectivity(result);
  }

  void _handleConnectivity(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    if (!hasConnection && !_isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isOffline = true);
        _showOfflineSnackBar();
      });
    } else if (hasConnection && _isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isOffline = false);
        _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      });
    }
  }

  void _showOfflineSnackBar() {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(days: 1),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('No Internet Connection'),
            TextButton(
              onPressed: _checkInitialConnection,
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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
            /* NavigationDestination(
              icon: Icon(Icons.language_outlined),
              selectedIcon: Icon(Icons.language_rounded),
              label: 'Language',
            ), */
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
      ),
    );
  }
}
