import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreams_decoder/pages/dream_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Upgrade extends StatefulWidget {
  const Upgrade({super.key});

  @override
  State<Upgrade> createState() => _UpgradeState();
}

Widget profileOption(IconData icon, String title, String description,
    String dollar, BuildContext context, VoidCallback func) {
  return Card(
    color: Colors.grey.shade900,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: TextStyle(color: Colors.white70)),
      trailing: Text(
        "\$$dollar",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onTap: func,
    ),
  );
}

class _UpgradeState extends State<Upgrade> {
  Future<void> upgradeSubscription(String plan) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      String userId = currentUser.uid;
      QuerySnapshot userData = await FirebaseFirestore.instance
          .collection("User")
          .where("user_id", isEqualTo: userId)
          .limit(1)
          .get();

      print(userData);

      if (userData.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userData.docs.first;
        String docId = userDoc.id;

        int currentMessages = userDoc['message_limit'];

        int additionalMessages = 0;
        switch (plan) {
          case "silver":
            additionalMessages = 50;
            break;
          case "gold":
            additionalMessages = 100;
            break;
          case "diamond":
            additionalMessages = 200;
            break;
        }

        int newLimit = currentMessages + additionalMessages;

        await FirebaseFirestore.instance
            .collection("User")
            .doc(docId)
            .update({'message_limit': newLimit});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upgraded to $plan! New limit: $newLimit messages"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DreamHistory()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User document not found"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error upgrading subscription: $e"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Upgrade Subscription",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          profileOption(
              Icons.add_ic_call_outlined,
              "Silver",
              "This Subscription Gives you 50 more messages",
              "20",
              context, () {
            upgradeSubscription("silver");
          }),
          profileOption(
              Icons.add_ic_call_outlined,
              "Gold",
              "This Subscription Gives you 100 more messages",
              "40",
              context, () {
            upgradeSubscription("gold");
          }),
          profileOption(
              Icons.add_ic_call_outlined,
              "Diamond",
              "This Subscription Gives you 200 more messages",
              "60",
              context, () {
            upgradeSubscription("diamond");
          }),
        ],
      ),
    );
  }
}
