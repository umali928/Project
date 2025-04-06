import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile.dart'; // Import ProfileScreen

void main() {
  runApp(policy());
}

class policy extends StatelessWidget {
  const policy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        primaryColor: Color(0xFF800000), // Maroon
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF800000),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: PrivacyPolicyScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => settings(), // Go back to ProfilePage
              ),
            ); // Go back
          },
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth < 600 ? 20 : 100;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLastUpdated(),
                const SizedBox(height: 24),
                _buildTitle('Your Privacy Matters'),
                _buildParagraph(
                  'At LSPUMART, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application.',
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('1. Information We Collect'),
                _buildBulletPoint(
                    'Personal Information: Name, email, phone number when you register'),
                _buildBulletPoint(
                    'Payment Information: Credit card details processed through secure payment gateways'),
                _buildBulletPoint(
                    'Device Information: IP address, browser type, operating system'),
                _buildBulletPoint(
                    'Usage Data: Pages visited, time spent, features used'),
                const SizedBox(height: 24),
                _buildSectionTitle('2. How We Use Your Information'),
                _buildBulletPoint(
                    'To process your transactions and deliver products'),
                _buildBulletPoint('To improve our app and customer service'),
                _buildBulletPoint('To prevent fraud and enhance security'),
                const SizedBox(height: 24),
                _buildSectionTitle('3. Data Sharing'),
                _buildParagraph(
                  'We do not sell your personal information. We may share data with:',
                ),
                _buildBulletPoint(
                    'Service providers who assist with payment processing, shipping, etc.'),
                _buildBulletPoint('Legal authorities when required by law'),
                const SizedBox(height: 24),
                _buildSectionTitle('4. Data Security'),
                _buildParagraph(
                  'We implement industry-standard security measures including encryption, secure servers, and regular audits to protect your data.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('5. Your Rights'),
                _buildBulletPoint(
                    'Access, update, or delete your personal information'),
                _buildBulletPoint('Opt-out of marketing communications'),
                _buildBulletPoint('Request data portability'),
                _buildBulletPoint('Withdraw consent where applicable'),
                const SizedBox(height: 24),
                _buildSectionTitle('6. Cookies and Tracking'),
                _buildParagraph(
                  'We use cookies and similar technologies to enhance your experience, analyze usage, and deliver personalized ads. You can manage cookie preferences in your browser settings.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('7. Changes to This Policy'),
                _buildParagraph(
                  'We may update this policy periodically. We will notify you of significant changes through the app or via email. Your continued use after changes constitutes acceptance.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('8. Contact Us'),
                _buildParagraph(
                  'For questions about this privacy policy or your personal data, please contact our Data Protection Officer at:',
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Thank you for trusting LSPUMART!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLastUpdated() => Text(
        'Last Updated: April 6, 2025',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );

  Widget _buildTitle(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF800000),
        ),
      );

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF800000),
          ),
        ),
      );

  Widget _buildBulletPoint(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6, right: 8),
              child: Icon(Icons.circle, size: 8, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      );

  Widget _buildParagraph(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
      );
}
