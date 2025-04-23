import 'package:chatter_bridge/utilities/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Set immediately
      userName = user.displayName;
      userEmail = user.email;
      userPhotoUrl = user.photoURL;

      // Try to update from Firestore if it exists
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? user.displayName;
          userEmail = doc['email'] ?? user.email;
          userPhotoUrl = doc['photoUrl'] ?? user.photoURL;
        });
      } else {
        setState(() {}); // still need this to trigger UI update
      }
    }
  }

  Future<void> _handleLogout() async {
    await _googleSignIn.signOut();
    if (!mounted) return;
    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        loginPageRoute,
      ); // Replace with your login route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // User Info Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40, // Bigger image
                    backgroundImage:
                        userPhotoUrl != null
                            ? NetworkImage(userPhotoUrl!)
                            : const AssetImage("assets/images/profile.jpg")
                                as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    userEmail ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 101, 100, 100),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.logout, "Logout", onTap: _handleLogout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      onTap: onTap,
    );
  }
}
