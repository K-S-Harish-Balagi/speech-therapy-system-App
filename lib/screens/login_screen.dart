import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_widgets.dart';
import 'forget_pwd_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'therapist_screen.dart';
import 'supervisor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _patientIdController = TextEditingController();
  final _passController      = TextEditingController();
  bool _isLoading   = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _patientIdController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_patientIdController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = UserModel(
      patientId: _patientIdController.text.trim(),
      password:  _passController.text.trim(),
    );

    final role = await AuthService.login(user);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ID or Password')),
      );
      return;
    }

    final id = _patientIdController.text.trim();

    if (role == "therapist") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TherapistScreen(therapistId: id)),
      );
    } else if (role == "supervisor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SupervisorScreen(supervisorId: id)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to your account',
      children: [
        TextField(
          controller: _patientIdController,
          decoration: const InputDecoration(
            labelText: 'ID',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        kFieldGap,
        TextField(
          controller: _passController,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () =>
                  setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
        kSectionGap,
        AppButton(
          label: 'Sign In',
          onPressed: _handleLogin,
          isLoading: _isLoading,
        ),
        kFieldGap,
        const LabelDivider('or'),
        kFieldGap,
        AppButton(
          label: 'Create Account',
          variant: AppButtonVariant.outlined,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
        ),
      ],
    );
  }
}