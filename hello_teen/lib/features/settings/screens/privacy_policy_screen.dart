import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for HelloTeen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: October 2023',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              '1. Information We Collect\n\n'
              'We collect information you provide directly to us when you create an account, such as your nickname, birthday, and gender. If you use features like the Period Tracker or Mental Health Check-In, we securely store that data to provide you with insights and predictions.\n\n'
              '2. How We Use Your Information\n\n'
              'We use your information to operate and maintain the HelloTeen app, personalize your experience, provide predictive scheduling for the Period Tracker, and send you push notifications if you have opted in.\n\n'
              '3. Data Security\n\n'
              'We implement reasonable security measures using Firebase to protect the security of your personal information both online and offline.\n\n'
              '4. Your Choices\n\n'
              'You can update, correct, or delete your profile information at any time within the app settings. You can also opt-out of push notifications in the Settings screen.\n\n'
              '5. Contact Us\n\n'
              'If you have any questions about this Privacy Policy, please contact us at support@helloteen.app.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
