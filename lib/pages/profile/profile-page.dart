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
      style: TextStyle(color: Color(0xFFDFBAEF), fontSize: 15),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          filled: true,
          fillColor: Color(0xFF301530),
          hintText: displayName,
          hintStyle: TextStyle(fontSize: 15, color: Color(0xFFDFBAEF)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF301530))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF301530))),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF301530)))),
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
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 5,
      ),
      DropdownButtonFormField(
        value: initialValue,
        dropdownColor: Color(0xFF301530),
        hint: Text(displayName, style: TextStyle(color: Color(0xFFDFBAEF))),
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFF301530),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF301530)),
          ),
        ),
        items: dropdownItems.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: TextStyle(color: Color(0xFFDFBAEF))), // Display text
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
      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData));

      if (response.statusCode == 200) {
        showSuccessSnackbar(context, "Updated Successfully");
        await Provider.of<UserProvider>(context, listen: false).getUserData();
      }
    } catch (e) {
      debugPrint("Failed to update user details $e");
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFF180E18),
        leading: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFF301530),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFFE152C2),
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
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
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE152C2),
                  disabledBackgroundColor: Color(0xFFE152C2),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text("Save & Continue",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
