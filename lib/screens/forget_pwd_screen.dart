import 'package:flutter/material.dart';
import '../theme/app_widgets.dart';
import 'reset_pwd_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _patientIdController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_patientIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your Patient ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
            patientId: _patientIdController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Forgot Password',
      subtitle: 'Enter your Patient ID to continue',
      children: [
        TextField(
          controller: _patientIdController,
          decoration: const InputDecoration(
            labelText: 'Patient ID',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        kSectionGap,
        AppButton(label: 'Continue', onPressed: _handleNext),
        kFieldGap,
        AppButton(
          label: 'Back to Login',
          variant: AppButtonVariant.outlined,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}