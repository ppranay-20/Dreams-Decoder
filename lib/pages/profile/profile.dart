import 'package:dreams_decoder/pages/auth/loggedout.dart';
import 'package:dreams_decoder/pages/payments/upgrade.dart';
import 'package:dreams_decoder/pages/privacy/privacy.dart';
import 'package:dreams_decoder/pages/profile/profile-page.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
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
    color: Colors.grey.shade900,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: TextStyle(color: Colors.white70)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
      onTap: onTap,
    ),
  );
}

void upgradeSubscription(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Upgrade()));
}

void navigateProfilePage(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => ProfilePage()));
}

class _ProfileState extends State<Profile> {
  final storage = const FlutterSecureStorage();

  signOut() async {
    await storage.delete(key: 'token');
    showSuccessSnackbar(context, "Logged out successfully");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoggedOut()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            profileOption(
                Icons.person,
                "Profile Settings",
                "Edit you profile Information",
                context,
                () => navigateProfilePage(context)),
            profileOption(Icons.message, "Contact Us",
                "Get In touch with our team", context, () {}),
            profileOption(Icons.lock, "Privacy", "Manage your privacy settings",
                context, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                }),
            SizedBox(
              height: 8,
            ),
            ElevatedButton.icon(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Logout",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
