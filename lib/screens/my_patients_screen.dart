import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class MyPatientsScreen extends StatefulWidget {
  const MyPatientsScreen({super.key});

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  List<dynamic> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await AuthService.getMyPatients();
    if (!mounted) return;
    setState(() {
      _patients = data["patients"] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No patients assigned yet',
                style: AppText.muted),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? (w - 460) / 2 : 16,
            vertical: 16,
          ),
          itemCount: _patients.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final p = _patients[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      (p["name"] as String? ?? "?")
                          .trim()
                          .isNotEmpty
                          ? (p["name"] as String)
                          .trim()[0]
                          .toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          p["name"] ?? "Unknown",
                          style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p["patientId"] ?? "",
                          style: AppText.muted,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}