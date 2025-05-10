import 'dart:convert';
import 'dart:ui';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:flutter/material.dart';
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
  String isPlanSelected = '';

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
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            paymentPlans = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            paymentPlans = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          paymentPlans = [];
          isLoading = false;
        });
        showErrorSnackBar(context, "Failed to load payment plans");
      }
    } catch (e) {
      setState(() {
        paymentPlans = [];
        isLoading = false;
      });
      debugPrint("An error occurred $e");
      showErrorSnackBar(context, "Failed to load payment plans");
    }
  }

  void upgradeSubscription() async {
    if (selectedPlan == null) {
      showErrorSnackBar(context, "Please select a plan first");
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
      backgroundColor: Color(0xFF180C12),
      insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFDD4594),
              ),
            )
          : Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Spacer(),
                      Container(
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          color: Color(0xFF330E22),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Color(0xFFDD4594),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Plans and pricing",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'MinionPro'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You're presently enjoying a complimentary plan to delve into the meanings of your dreams with your guide, Murka. This includes 20 messages, each with a 500-character limit.",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF330E22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF8B2359), width: 1),
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFDD4594),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Subscription",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: paymentPlans.isEmpty
                        ? Center(
                            child: Text(
                              "No payment plans available",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (paymentPlans.length > 0)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPlan = paymentPlans[0];
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(15),
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Color(0xFF330E22),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Color(0xFF8B2359),
                                              width: 2),
                                          boxShadow: selectedPlan ==
                                                  paymentPlans[0]
                                              ? [
                                                  BoxShadow(
                                                    color: Color(0xFF8B2359),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ]
                                              : []),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF671943),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Color(0xFFDD4594),
                                                      width: 1),
                                                ),
                                                child: selectedPlan ==
                                                        paymentPlans[0]
                                                    ? Icon(
                                                        Icons.check,
                                                        color:
                                                            Color(0xFFDD4594),
                                                        size: 10,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Mild Dreamer",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'MinionPro',
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Once or twice each week, you drift into the tender embrace of the dreamworld.",
                                            style: TextStyle(
                                              color: Color(0xFFFFDCEE),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.04,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "100 messages per month",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "500 character limit per message",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            "\$9.99 a month",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (paymentPlans.length > 1)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPlan = paymentPlans[1];
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(15),
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF370632),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Color(0xFF970D8A), width: 2),
                                        boxShadow:
                                            selectedPlan == paymentPlans[1]
                                                ? [
                                                    BoxShadow(
                                                      color: Color(0xFF970D8A),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ]
                                                : [],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4F0948),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Color(0xFF970D8A),
                                                      width: 1),
                                                ),
                                                child: selectedPlan ==
                                                        paymentPlans[1]
                                                    ? Icon(
                                                        Icons.check,
                                                        color:
                                                            Color(0xFFE41DD1),
                                                        size: 10,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Serious Dreamer",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'MinionPro',
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Nearly every dawn, you steal into the boundless haven of slumber.",
                                            style: TextStyle(
                                              color: Color(0xFFFFDCEE),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.04,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "200 messages per month",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "800 character limit per message",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            "\$19.99 a month",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (paymentPlans.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPlan = paymentPlans[2];
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(15),
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF20032F),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Color(0xFF822BAA), width: 2),
                                        boxShadow:
                                            selectedPlan == paymentPlans[2]
                                                ? [
                                                    BoxShadow(
                                                      color: Color(0xFF822BAA),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ]
                                                : [],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF3D0657),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Color(0xFF822BAA),
                                                      width: 1),
                                                ),
                                                child: selectedPlan ==
                                                        paymentPlans[2]
                                                    ? Icon(
                                                        Icons.check,
                                                        color:
                                                            Color(0xFFE41DD1),
                                                        size: 10,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Unreal Dreamer",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'MinionPro',
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "You dwell more deeply in the tender shadows of repose than in the bright hours of wakefulness, and it's totally okay 👀",
                                            style: TextStyle(
                                              color: Color(0xFFFFDCEE),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.04,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "100 messages per month",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Color(0xFFDD4594),
                                                size: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "500 character limit per message",
                                                style: TextStyle(
                                                  color: Color(0xFFFFDCEE),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.04,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            "\$39.99 a month",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isPaymentLoading || selectedPlan == null
                        ? null
                        : () => upgradeSubscription(),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      backgroundColor: Color(0xFFDD4594),
                      disabledBackgroundColor:
                          Color(0xFFDD4594).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isPaymentLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1,
                            ),
                          )
                        : Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
