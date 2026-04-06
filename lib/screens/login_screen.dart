import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_widgets.dart';
import 'forget_pwd_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _patientIdController = TextEditingController(text: 'PAT23377');
  // final _patientIdController = TextEditingController();
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

    final success = await AuthService.login(user);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Patient ID or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthLayout owns the Scaffold — no double-Scaffold issue.
    // On mobile it fills the screen. On web (>500px) it shows a centred card.
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to your patient account',
      children: [
        TextField(
          controller: _patientIdController,
          decoration: const InputDecoration(
            labelText: 'Patient ID',
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
        // Forgot password — restored and wired
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen()),
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