import 'package:murkaverse/pages/auth/loggedout.dart';
import 'package:murkaverse/pages/privacy/privacy.dart';
import 'package:murkaverse/pages/profile/profile-page.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

Widget profileOption(IconData icon, String title, String description,
    BuildContext context, VoidCallback onTap) {
  return Card(
    color: Color(0xFF180E18),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Color(0xFF8B2359),
        width: 1.0,
      ),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 60,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF330E22),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.15,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(Icons.chevron_right, color: Color(0xFF592B65), size: 24),
      ),
      onTap: onTap,
    ),
  );
}

void navigateProfilePage(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => ProfilePage()));
}

class _ProfileState extends State<Profile> {
  final storage = const FlutterSecureStorage();

  signOut() async {
    await storage.delete(key: 'token');
    if (!mounted) return;
    showSuccessSnackbar(context, "Logged out successfully");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoggedOut()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Settings",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20,
            ),
            profileOption(
                Icons.person,
                "Profile Settings",
                "Edit you profile Information",
                context,
                () => navigateProfilePage(context)),
            profileOption(Icons.message, "Contact Us",
                "Get In touch with our team", context, () {}),
            profileOption(
                Icons.lock, "Privacy", "Manage your privacy settings", context,
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
            }),
            SizedBox(
              height: 8,
            ),
            ElevatedButton(
              onPressed: () {
                signOut();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFF051D2D)),
                child: Container(
                  height: 60, // Match image height
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Row(
                    children: [
                      // Blue square on the left with icon
                      Container(
                        width: 60, // Square left section
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF1972A9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      // Middle text section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Log Out",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Sign out of your account",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right arrow icon
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
