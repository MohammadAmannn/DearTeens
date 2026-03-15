import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: October 2023',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'Please read these terms and conditions carefully before using HelloTeen.\n\n'
              '1. Acknowledgment\n\n'
              'These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. HelloTeen is strictly an educational tool.\n\n'
              '2. Medical Disclaimer\n\n'
              'The content provided in HelloTeen is for educational purposes only. It does not replace professional medical advice, diagnosis, or treatment. Always consult a pediatrician or general practitioner for specific medical concerns.\n\n'
              '3. User Accounts\n\n'
              'When you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms.\n\n'
              '4. Changes to These Terms\n\n'
              'We reserve the right, at Our sole discretion, to modify or replace these Terms at any time.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
