import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../utils/ui_helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController           = TextEditingController();
  final _emailController          = TextEditingController();
  final _passwordController       = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  DateTime?     _selectedDob;
  String?       _selectedGender;
  String?       _selectedProblem;
  PlatformFile? _idDoc;
  bool _loading        = false;
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  static const _genders  = ['Male', 'Female', 'Other'];
  static const _problems = ['Apraxia', 'Aphasia', 'Stuttering', 'Others'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) setState(() => _idDoc = result.files.first);
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final user = UserModel(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      password: _passwordController.text.trim(),
      gender:   _selectedGender,
      problem:  _selectedProblem,
      dob:      _selectedDob?.toIso8601String(),
    );

    final errors = user.validate();
    if (errors.isNotEmpty) {
      UIHelpers.showError(context, errors.first);
      return;
    }

    setState(() => _loading = true);
    final data = await AuthService.register(user, _idDoc);
    setState(() => _loading = false);
    if (!mounted) return;

    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Registered! Your Patient ID: ${data["patientId"]}'),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else {
      UIHelpers.showError(
          context, data['message'] ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Register as a new patient',
      children: [
        // ── Personal ──────────────────────────────────────────────────────
        const SectionLabel('Personal details'),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        kFieldGap,
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              _selectedDob == null
                  ? 'Select date'
                  : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
              style: _selectedDob == null ? AppText.muted : AppText.body,
            ),
          ),
        ),
        kFieldGap,
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.wc_outlined),
          ),
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        kFieldGap,
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        // ── Condition ─────────────────────────────────────────────────────
        kSectionGap,
        const SectionLabel('Condition'),
        DropdownButtonFormField<String>(
          initialValue: _selectedProblem,
          decoration: const InputDecoration(
            labelText: 'Speech problem',
            prefixIcon: Icon(Icons.medical_information_outlined),
          ),
          items: _problems
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _selectedProblem = v),
        ),

        // ── Security ──────────────────────────────────────────────────────
        kSectionGap,
        const SectionLabel('Security'),
        TextField(
          controller: _passwordController,
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
        kFieldGap,
        TextField(
          controller: _repeatPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),

        // ── ID Document ───────────────────────────────────────────────────
        kSectionGap,
        const SectionLabel('ID Document (optional)'),
        _idDoc == null
            ? AppButton(
          label: 'Upload ID Document',
          variant: AppButtonVariant.outlined,
          icon: Icons.upload_file_outlined,
          onPressed: _pickDocument,
        )
            : Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _idDoc!.name,
                  style:
                  AppText.body.copyWith(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _idDoc = null),
                child: const Icon(Icons.close,
                    color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),

        kSectionGap,
        AppButton(
          label: 'Register',
          onPressed: _registerUser,
          isLoading: _loading,
        ),
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