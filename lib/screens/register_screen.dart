import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/ui_helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  DateTime? selectedDob;
  String? selectedGender;
  String? selectedProblem;
  PlatformFile? idDoc;
  bool loading = false;

  final List<String> genders = ["Male", "Female", "Other"];

  final List<String> problems = [
    "Apraxia",
    "Aphasia",
    "Stuttering",
    "Others"
  ];

  /// DATE PICKER
  Future<void> pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  Future<void> pickDocument() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        idDoc = result.files.first;
      });
    }
  }

  /// REGISTER USER
  Future<void> registerUser() async {

    if (passwordController.text != repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    UserModel user = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      gender: selectedGender,
      problem: selectedProblem,
      dob: selectedDob?.toIso8601String(),
    );

    final errors = user.validate();

    if (errors.isNotEmpty) {
      UIHelpers.showError(context, errors.first);
      return;
    }

    setState(() {
      loading = true;
    });

    final data = await AuthService.register(user, idDoc);

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Registered! Your Patient ID: ${data["patientId"]}",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      UIHelpers.showError(context, data["message"] ?? "Registration failed");

    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Container(
            width: screenWidth > 500 ? 420 : double.infinity,

            padding: const EdgeInsets.all(32),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: screenWidth > 500
                  ? const [
                BoxShadow(
                  blurRadius: 15,
                  color: Colors.black12,
                  offset: Offset(0, 5),
                )
              ]
                  : [],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// NAME
                TextField(
                  controller: nameController,
                  decoration:
                  const InputDecoration(labelText: "Full Name"),
                ),

                const SizedBox(height: 20),

                /// DOB
                InkWell(
                  onTap: pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDob == null
                          ? "Select Date"
                          : "${selectedDob!.day}/${selectedDob!.month}/${selectedDob!.year}",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// GENDER
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration:
                  const InputDecoration(labelText: "Gender"),
                  items: genders
                      .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g),
                  ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedGender = v),
                ),

                const SizedBox(height: 20),

                /// EMAIL
                TextField(
                  controller: emailController,
                  decoration:
                  const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                  const InputDecoration(labelText: "Password"),
                ),

                const SizedBox(height: 20),

                /// REPEAT PASSWORD
                TextField(
                  controller: repeatPasswordController,
                  obscureText: true,
                  decoration:
                  const InputDecoration(labelText: "Repeat Password"),
                ),

                const SizedBox(height: 20),

                /// PROBLEM
                DropdownButtonFormField<String>(
                  initialValue: selectedProblem,
                  decoration:
                  const InputDecoration(labelText: "Problem"),
                  items: problems
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedProblem = v),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: pickDocument,
                  child: Text(
                    idDoc == null
                        ? "Upload ID Document"
                        : "Document Selected: ${idDoc!.name}",
                  ),
                ),

                const SizedBox(height: 25),

                /// REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : registerUser,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
                  ),
                ),

                const SizedBox(height: 20),

                /// BACK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Login"),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}