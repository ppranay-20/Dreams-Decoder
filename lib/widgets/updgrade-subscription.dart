import 'dart:convert';
import 'dart:ui';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:dreams_decoder/utils/getUserData.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PaymentDialog();
    }
  );
}

class PaymentDialog extends StatefulWidget {
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool isLoading = true;
  List<dynamic> paymentPlans = [];
  dynamic selectedPlan;

  @override
  void initState() {
    super.initState();
    getPaymentPlans();
  }

  void getPaymentPlans() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final url = getAPIUrl('payment-plans');
      final response = await http.get(
        url, 
        headers: {'Content-Type': 'application/json'}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentPlans = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorSnackBar(context, "Failed to load payment plans");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("An error occurred $e");
    }
  }

  void upgradeSubscription() async {
    if (selectedPlan == null) {
      showErrorSnackBar(context, "Please select a plan first");
      return;
    }
  
    final customerId = await getIdFromJWT();
    final paymentPlanId = selectedPlan['id'];
    String now = DateTime.now().toUtc().toIso8601String();
    final int expirationDays = selectedPlan['expiration_days'];
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentPayload)
      );

      setState(() {
        isLoading = false;
      });

      if(response.statusCode == 200) {
        showSuccessSnackbar(context, "Payment Done Successfully");
        await getUserData();
        Navigator.pop(context);
      } else {
        showErrorSnackBar(context, "Failed to update payment status");
      }
    } catch (e) {
      showErrorSnackBar(context, "An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Icon(Icons.nightlight_round, color: Colors.orangeAccent, size: 30),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Add Messages to your account!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                
                // Display plans from API
                paymentPlans.isEmpty 
                  ? Text("No plans available", style: TextStyle(color: Colors.grey))
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: paymentPlans.map<Widget>((plan) {
                      bool isSelected = selectedPlan != null && selectedPlan['id'] == plan['id'];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.blue : Colors.pinkAccent[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPlan = plan;
                          });
                        },
                        child: Text(
                          "+${plan['message_limit']}",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.red
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 10),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: upgradeSubscription,
                  child: Text("Continue", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
      ),
    );
  }
}