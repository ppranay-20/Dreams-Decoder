import 'dart:convert';
import 'dart:ui';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void showPaymentDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PaymentDialog();
      });
}

class PaymentDialog extends StatefulWidget {
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool isLoading = true;
  List<dynamic> paymentPlans = [];
  dynamic selectedPlan;
  int? amount;
  bool isPaymentLoading = false;

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
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

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

    final key = dotenv.env['RAZORPAY_TEST_API_KEY'];

    if (key == null || key.isEmpty) {
      showErrorSnackBar(context, "Payment Configration Error");
      return;
    }

    setState(() {
      isPaymentLoading = true;
    });

    try {
      final customerId = await getIdFromJWT();
      final paymentPlanId = selectedPlan['id'];
      String now = DateTime.now().toUtc().toIso8601String();
      final int expirationDays = selectedPlan['expiration_days'];
      DateTime expirationDate =
          DateTime.now().add(Duration(days: expirationDays));

      final paymentPayload = {
        'customer_id': customerId,
        'payment_plan_id': paymentPlanId,
        'payment_date': now,
        'expiration_date': expirationDate.toUtc().toIso8601String()
      };

      try {
        final url = getAPIUrl('payments');
        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(paymentPayload));

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          if (mounted) {
            showSuccessSnackbar(context, "Payment Done Successfully");
            await Provider.of<UserProvider>(context, listen: false)
                .getUserData();
            Navigator.pop(context);
          }
        } else {
          showErrorSnackBar(context, "Payment Failed");
        }
      } catch (e) {
        showErrorSnackBar(context, "An error occurred: $e");
      }
    } catch (err) {
      showErrorSnackBar(context, "Error opening payment: $err");
    } finally {
      setState(() {
        isPaymentLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF180E18),
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF180E18),
          borderRadius: BorderRadius.circular(15),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Add Messages to your account!",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),

                    // Display plans from API
                    paymentPlans.isEmpty
                        ? Text("No plans available",
                            style: TextStyle(color: Colors.grey))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: paymentPlans.map<Widget>((plan) {
                              bool isSelected = selectedPlan != null &&
                                  selectedPlan['id'] == plan['id'];
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Color(0xFFE152C2)
                                      : Color(0xFF101D3C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: BorderSide(
                                      color: isSelected
                                          ? Color(0xFFE152C2)
                                          : Color(0xFF699DFF)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedPlan = plan;
                                    amount = plan['amount'];
                                  });
                                },
                                child: Text(
                                  "+${plan['message_limit']}",
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.red),
                                ),
                              );
                            }).toList(),
                          ),

                    SizedBox(height: 10),
                    Text(
                      "Amount: ${amount ?? "Select a plan"}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE152C2),
                        disabledBackgroundColor: Color(0xFFE152C2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: isPaymentLoading ? null : upgradeSubscription,
                      child: isPaymentLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1,
                              ),
                            )
                          : Text("Continue",
                              style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
