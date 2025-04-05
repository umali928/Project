import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const PrivacyPolicyScreen(),
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
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Last Updated: May 15, 2023',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Privacy Matters',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At MyShop, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('1. Information We Collect'),
            _buildBulletPoint('Personal Information: Name, email, phone number when you register'),
            _buildBulletPoint('Payment Information: Credit card details processed through secure payment gateways'),
            _buildBulletPoint('Device Information: IP address, browser type, operating system'),
            _buildBulletPoint('Usage Data: Pages visited, time spent, features used'),
            
            const SizedBox(height: 24),
            _buildSectionTitle('2. How We Use Your Information'),
            _buildBulletPoint('To process your transactions and deliver products'),
            _buildBulletPoint('To improve our app and customer service'),
            _buildBulletPoint('To send promotional emails (you can opt-out anytime)'),
            _buildBulletPoint('To prevent fraud and enhance security'),
            
            const SizedBox(height: 24),
            _buildSectionTitle('3. Data Sharing'),
            const Text(
              'We do not sell your personal information. We may share data with:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            _buildBulletPoint('Service providers who assist with payment processing, shipping, etc.'),
            _buildBulletPoint('Legal authorities when required by law'),
            
            const SizedBox(height: 24),
            _buildSectionTitle('4. Data Security'),
            const Text(
              'We implement industry-standard security measures including encryption, secure servers, and regular audits to protect your data.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('5. Your Rights'),
            _buildBulletPoint('Access, update, or delete your personal information'),
            _buildBulletPoint('Opt-out of marketing communications'),
            _buildBulletPoint('Request data portability'),
            _buildBulletPoint('Withdraw consent where applicable'),
            
            const SizedBox(height: 24),
            _buildSectionTitle('6. Cookies and Tracking'),
            const Text(
              'We use cookies and similar technologies to enhance your experience, analyze usage, and deliver personalized ads. You can manage cookie preferences in your browser settings.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('7. Changes to This Policy'),
            const Text(
              'We may update this policy periodically. We will notify you of significant changes through the app or via email. Your continued use after changes constitutes acceptance.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('8. Contact Us'),
            const Text(
              'For questions about this privacy policy or your personal data, please contact our Data Protection Officer at:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle email tap
              },
              child: const Text(
                'privacy@myshop.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Thank you for trusting MyShop',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(
              Icons.circle,
              size: 8,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}