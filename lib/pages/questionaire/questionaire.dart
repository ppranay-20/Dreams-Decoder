import 'dart:ui';

import 'package:murkaverse/pages/questionaire/questions/question-four.dart';
import 'package:murkaverse/pages/questionaire/questions/question-one.dart';
import 'package:murkaverse/pages/questionaire/questions/question-three.dart';
import 'package:murkaverse/pages/questionaire/questions/question-two.dart';
import 'package:murkaverse/widgets/main-screen.dart';
import 'package:flutter/material.dart';

void showEndChatQuestionnaire(BuildContext context) {
  final pageController = PageController();
  bool wokeFromSleep = true;
  bool nightmare = false;
  String dreamDescription = '';
  int currentPage = 0;
  List<String> selectedEmotions = [];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Color(0xFF180C12), // Dark purple background
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF8B2359),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button at top right
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color(0xFF330E22),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFFDD4594),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Title
                      Text(
                        "The Chat has ended",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MinionPro',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      // Description
                      Text(
                        "By responding to the following 4 questions about your dream, you'll help us better analyze the patterns of dreaming and their connection to physical responses.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24),

                      // Question 1
                      SizedBox(
                        height: 200,
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: pageController,
                          children: [
                            QuestionOne(
                              selectedEmotions: selectedEmotions,
                              onChanged: (List<String> updatedEmotions) {
                                setState(() {
                                  selectedEmotions = updatedEmotions;
                                });
                              },
                            ),
                            QuestionTwo(
                              onChanged: (value) {
                                setState(() {
                                  wokeFromSleep = value;
                                });
                              },
                              wokeFromSleep: wokeFromSleep,
                            ),
                            QuestionThree(
                              onChanged: (value) {
                                setState(() {
                                  nightmare = value;
                                });
                              },
                              nightmare: nightmare,
                            ),
                            QuestionFour(
                              dreamDescription: dreamDescription,
                              onChanged: (value) {
                                setState(() {
                                  dreamDescription = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Continue button
                      ElevatedButton(
                        onPressed: () {
                          if (currentPage < 3) {
                            setState(() {
                              currentPage++;
                              pageController.animateToPage(
                                currentPage,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDD4594),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.5, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          currentPage == 3 ? "Submit" : "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: currentPage >= 0
                                  ? Color(0xFFDD4594)
                                  : Color(0xFF8B2359),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: currentPage >= 1
                                  ? Color(0xFFDD4594)
                                  : Color(0xFF8B2359),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: currentPage >= 2
                                  ? Color(0xFFDD4594)
                                  : Color(0xFF8B2359),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: currentPage >= 3
                                  ? Color(0xFFDD4594)
                                  : Color(0xFF8B2359),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
