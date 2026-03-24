import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await AuthService.getProfile();
    if (!mounted) return;

    if (data['expired'] == true || data['success'] == false) {
      await AuthService.logout();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    setState(() {
      _profile   = data['profile'];
      _documents = data['documents'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 500;

    // Profile keeps its own Scaffold so the AppBar back button
    // works correctly on both mobile and web.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? (w - 460) / 2 : 20,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(name: _profile?['name']),
            const SizedBox(height: 20),
            _InfoCard(
              title: 'Patient Information',
              child: Column(
                children: [
                  InfoRow(
                      label: 'Email',
                      value: _profile?['email']),
                  InfoRow(
                      label: 'Gender',
                      value: _profile?['gender']),
                  InfoRow(
                      label: 'Date of Birth',
                      value: _profile?['dob']
                          ?.toString()
                          .split('T')
                          .first),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Condition',
              child: InfoRow(
                  label: 'Problem', value: _profile?['problem']),
            ),
            if (_documents.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Uploaded Documents',
                child: Column(
                  children: _documents
                      .map((doc) => _DocumentTile(doc: doc))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name});
  final String? name;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          (name ?? '?')[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? '—', style: AppText.screenTitle),
          const Text('Patient',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppText.sectionLabel),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.doc});
  final dynamic doc;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.insert_drive_file_outlined,
            color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc['docType'] ?? 'Document',
                  style: AppText.body
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(doc['url'] ?? '',
                  style: AppText.muted,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}