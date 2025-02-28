import 'dart:convert';

import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Upgrade extends StatefulWidget {
  const Upgrade({super.key});

  @override
  State<Upgrade> createState() => _UpgradeState();
}

Widget profileOption(IconData icon, String title, String description,
    int dollar, BuildContext context, VoidCallback func) {
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
  bool isLoading = true;
  List<dynamic> paymentPlans = [];

  @override
  void initState() {
    super.initState();
    getPaymentPlans();
  }

  void getPaymentPlans() async {
    try {
      final url = getAPIUrl('payment-plans');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          paymentPlans = data['data'];
        });
      } else {
        if(!mounted) return;
        setState(() => isLoading = false);
        showErrorSnackBar(context, "Failed to load payment plans");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("An error occured $e");
    }
  }

  void upgradeSubscription(dynamic plan) async {
    final customerId = await getIdFromJWT();
    final paymentPlanId = plan['id'];
    String now = DateTime.now().toUtc().toIso8601String();
    final int expirationDays = plan['expiration_days'];
    DateTime expirationDate = DateTime.now().add(Duration(days: expirationDays));

    final paymentPayload = {
      'customer_id': customerId,
      'payment_plan_id': paymentPlanId,
      'payment_date': now,
      'expiration_date': expirationDate.toUtc().toIso8601String()
    };

    try {
      final url = getAPIUrl('payments');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(paymentPayload)
      );

      if(response.statusCode == 200) {
        debugPrint("Payment Updated Successfully");
        showSuccessSnackbar(context, "Payment Done Successfully");
      } else {
         debugPrint("Failed to update payment status");
      }
    } catch (e) {
      debugPrint("An error Occured $e");
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : paymentPlans.isEmpty
                ? Center(
                    child: Text("No payment plans available",
                        style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    itemCount: paymentPlans.length,
                    itemBuilder: (context, index) {
                      final plan = paymentPlans[index];
                      return profileOption(
                          Icons.upgrade,
                           plan['name'],
                          "This is basic plan",
                          plan['amount'],
                          context,
                          () => upgradeSubscription(plan));
                    },
                  ));
  }
}
