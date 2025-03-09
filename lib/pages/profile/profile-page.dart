import 'dart:convert';

import 'package:dreams_decoder/providers/user-provider.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

Widget _buildInputField(
    String displayName, TextInputType type, TextEditingController controller) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
      displayName,
      style: TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    ),
    SizedBox(
      height: 5,
    ),
    TextField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: Colors.black, fontSize: 15),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          filled: true,
          fillColor: Colors.white,
          hintText: displayName,
          hintStyle: TextStyle(fontSize: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.blue)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey))),
    ),
  ]);
}

Widget _buildDropdown(String displayName, List<String> dropdownItems,
    String? initialValue, ValueChanged onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        displayName,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      SizedBox(
        height: 5,
      ),
      DropdownButtonFormField(
        value: initialValue,
        dropdownColor: Colors.grey,
        hint: Text(displayName, style: TextStyle(color: Colors.grey)),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
        items: dropdownItems.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: TextStyle(color: Colors.black)), // Display text
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  var userData;
  bool isLoading = false;

  String? selectedGender;
  String? selectedOccupation;
  String? selectedCulturalGroup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeUser();
  }

  void initializeUser() async {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userData;
    if (user != null) {
      setState(() {
        userData = user;
        nameController.text = user['name'] ?? '';
        ageController.text = user['age']?.toString() ?? '';

        selectedGender = user['gender'];
        selectedOccupation = user['occupation'];
        selectedCulturalGroup = user['cultural_group'];
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void updateDetails() async {
    final formData = {
      "name": nameController.text.toString(),
      "email": userData['email'],
      "password": userData['password'],
      "age": int.tryParse(ageController.text),
      "gender": selectedGender,
      "occupation": selectedOccupation,
      "cultural_group": selectedCulturalGroup,
    };

    try {
      setState(() {
        isLoading = true;
      });
      final id = userData['id'];
      final url = getAPIUrl('users/$id');
      final response = await http.put(url,headers: {
        'Content-Type': 'application/json'
      }, body: jsonEncode(formData));

      if(response.statusCode == 200) {
        showSuccessSnackbar(context, "Updated Successfully");
        await Provider.of<UserProvider>(context, listen: false).getUserData();

      }
    } catch (e) {
      debugPrint("Failed to update user details $e");
    }
    finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                  ),
                ],
              ),
            SizedBox(height: 10,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                "Just a few things before you start!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                "Hey Joe! Let’s get to know each other before things get serious",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Image.asset(
                      'assets/murka.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My name is Murka and I will be your dream guide.",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "I like to sleep a lot and when\n i’m done sleeping,\n I will sleep some more.",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          softWrap: true,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      _buildInputField(
                          "Display Name", TextInputType.text, nameController),
                      SizedBox(
                        height: 20,
                      ),
                      _buildInputField("Age", TextInputType.numberWithOptions(),
                          ageController),
                      SizedBox(
                        height: 20,
                      ),
                      _buildDropdown(
                          "Gender", ["male", "female"], selectedGender,
                          (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      }),
                      SizedBox(
                        height: 20,
                      ),
                      _buildDropdown(
                          "Occupation",
                          ["Teacher", "Student", "Businessman"],
                          selectedOccupation, (value) {
                        setState(() {
                          selectedOccupation = value;
                        });
                      }),
                      SizedBox(
                        height: 20,
                      ),
                      _buildDropdown("Cultural Group", ["Group1", "Group2"],
                          selectedCulturalGroup, (value) {
                        setState(() {
                          selectedCulturalGroup = value;
                        });
                      })
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading ?
                SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ) 
                : Text("Update",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
