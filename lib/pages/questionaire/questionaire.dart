import 'package:dreams_decoder/pages/questionaire/questions/question-four.dart';
import 'package:dreams_decoder/pages/questionaire/questions/question-one.dart';
import 'package:dreams_decoder/pages/questionaire/questions/question-three.dart';
import 'package:dreams_decoder/pages/questionaire/questions/question-two.dart';
import 'package:dreams_decoder/widgets/main_screen.dart';
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
          return Dialog(
            backgroundColor: Color(0xFF301530), // Dark purple background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button at top right
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),

                  // Title
                  Text(
                    "The Chat has ended",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                    height: 300,
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

                  SizedBox(height: 24),

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
                      backgroundColor: Color(0xFFE152C2),
                      minimumSize: Size(double.infinity, 50),
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

                  SizedBox(height: 16),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: currentPage >= 0
                              ? Color(0xFFE152C2)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: currentPage >= 1
                              ? Color(0xFFE152C2)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: currentPage >= 2
                              ? Color(0xFFE152C2)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: currentPage >= 3
                              ? Color(0xFFE152C2)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
