import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFF180C12),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFF330E22),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFDD4594),
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          "Privacy",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'MinionPro',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Personal Data We Collect"),
            _buildParagraph(
              "We collect personal data directly from you through the app when you register, use our services, and interact with features. Here's what we collect:",
            ),
            _buildSubheading("Account Information"),
            _buildParagraph(
              "When you create an account with us, we collect your registration information including email address, username, password, and optional profile information. This helps us identify you and provide access to our services.",
            ),
            _buildSubheading("Dream Content and Analysis"),
            _buildParagraph(
              "The dreams you record, descriptions, emotions, tags, categories, and any other information you provide when using our dream analysis and tracking features.",
            ),
            _buildSubheading("Usage Information"),
            _buildParagraph(
              "Information about how you access and use our application, including time spent, features used, interaction patterns, and preferences. This helps us improve your experience.",
            ),
            _buildSubheading("Communications"),
            _buildParagraph(
              "If you communicate with us through the app, we may collect the information you provide, including message content, time of communication, and the context of the messages you send.",
            ),
            _buildSubheading("Device and Technical Information"),
            _buildParagraph(
              "Information about your device including device type, operating system, unique device identifiers, IP address, mobile network information, and standard web server log information.",
            ),
            _buildSectionTitle("2. How We Use Your Information"),
            _buildParagraph(
              "We use the information we collect to:",
            ),
            _buildBulletPoint("Provide, maintain, and improve our services"),
            _buildBulletPoint(
                "Personalize your experience and deliver relevant content"),
            _buildBulletPoint("Process and analyze your dreams"),
            _buildBulletPoint(
                "Communicate with you about updates, offers, and features"),
            _buildBulletPoint(
                "Protect the security and integrity of our platform"),
            _buildBulletPoint("Analyze usage patterns to enhance our services"),
            _buildSectionTitle("3. Data Sharing and Disclosure"),
            _buildParagraph(
              "We respect your privacy and are committed to protecting your personal information. We do not sell your personal data to third parties. However, we may share your information in the following circumstances:",
            ),
            _buildSubheading("Service Providers"),
            _buildParagraph(
              "We may share information with third-party vendors and service providers who perform services on our behalf, such as cloud storage, data analysis, and customer service.",
            ),
            _buildSubheading("Legal Requirements"),
            _buildParagraph(
              "We may disclose your information if required to do so by law or in response to valid requests by public authorities.",
            ),
            _buildSubheading("Business Transfers"),
            _buildParagraph(
              "If we're involved in a merger, acquisition, or sale of assets, your personal information may be transferred as part of that transaction.",
            ),
            _buildSectionTitle("4. Data Security"),
            _buildParagraph(
              "We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.",
            ),
            _buildSectionTitle("5. Your Rights and Choices"),
            _buildParagraph(
              "Depending on your location, you may have certain rights regarding your personal information:",
            ),
            _buildBulletPoint(
                "Access, update, or delete your personal information"),
            _buildBulletPoint("Object to our processing of your data"),
            _buildBulletPoint("Request restriction of processing"),
            _buildBulletPoint("Data portability rights"),
            _buildBulletPoint("Withdraw consent at any time"),
            _buildParagraph(
              "To exercise these rights, please contact us through the app's support feature or at the email address provided below.",
            ),
            _buildSectionTitle("6. Data Retention"),
            _buildParagraph(
              "We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.",
            ),
            _buildSectionTitle("7. Children's Privacy"),
            _buildParagraph(
              "Our services are not directed to children under the age of 16. We do not knowingly collect personal information from children under 16. If you become aware that a child has provided us with personal information without parental consent, please contact us.",
            ),
            _buildSectionTitle("8. Changes to This Privacy Policy"),
            _buildParagraph(
              "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date.",
            ),
            _buildSectionTitle("9. Contact Us"),
            _buildParagraph(
              "If you have any questions about this Privacy Policy or our data practices, please contact us at:",
            ),
            _buildParagraph(
              "support@dreamsdecoder.com",
              isBold: true,
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                "Last Updated: March 8, 2025",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubheading(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
