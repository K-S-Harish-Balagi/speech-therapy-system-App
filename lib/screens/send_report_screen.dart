import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({super.key});

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  PlatformFile? _file;
  bool _loading     = false;
  bool _fetchingSup = true;
  bool _fetchingPat = true;

  String? _supervisorName;
  String? _supervisorError;

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  String? _patientsError;

  @override
  void initState() {
    super.initState();
    _fetchSupervisor();
    _fetchPatients();
  }

  Future<void> _fetchSupervisor() async {
    setState(() { _fetchingSup = true; _supervisorError = null; });

    final data = await AuthService.getTherapistMe();
    if (!mounted) return;

    if (data["success"] == true) {
      final supId   = data["therapist"]["supervisorId"];
      final supData = await AuthService.getSupervisorName(supId);
      if (!mounted) return;

      setState(() {
        _supervisorName = supData["name"] ?? supId;
        _fetchingSup    = false;
      });
    } else {
      setState(() {
        _supervisorError = "Could not load supervisor info";
        _fetchingSup     = false;
      });
    }
  }

  Future<void> _fetchPatients() async {
    setState(() { _fetchingPat = true; _patientsError = null; });

    final data = await AuthService.getMyPatients();
    if (!mounted) return;

    if (data["success"] == true) {
      final list = List<Map<String, dynamic>>.from(data["patients"] ?? []);
      setState(() {
        _patients       = list;
        _fetchingPat    = false;
        // auto select first if only one
        if (list.length == 1) _selectedPatientId = list.first["patientId"];
      });
    } else {
      setState(() {
        _patientsError = "Could not load patients";
        _fetchingPat   = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.first;
      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File must be under 5MB')),
        );
        return;
      }
      setState(() => _file = file);
    }
  }

  Future<void> _sendReport() async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a report')),
      );
      return;
    }

    setState(() => _loading = true);

    final data = await AuthService.sendReport(
      file:      _file!,
      patientId: _selectedPatientId!,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report sent successfully')),
      );
      setState(() {
        _file              = null;
        _selectedPatientId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? 'Failed to send report')),
      );
    }
  }

  bool get _isReady =>
      !_loading && !_fetchingSup && !_fetchingPat && _supervisorError == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Report'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.upload_file, color: Colors.white70),
                  SizedBox(height: 10),
                  Text(
                    'Upload Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PDF or Image only (Max 5MB)',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SUPERVISOR INFO CARD
            _InfoCard(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Assigned Supervisor',
              loading: _fetchingSup,
              value: _supervisorError ?? _supervisorName ?? '—',
              isError: _supervisorError != null,
            ),

            const SizedBox(height: 12),

            // PATIENT DROPDOWN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Patient', style: AppText.muted),
                        const SizedBox(height: 4),
                        _fetchingPat
                            ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : _patientsError != null
                            ? Text(
                          _patientsError!,
                          style: AppText.body.copyWith(color: Colors.red),
                        )
                            : _patients.isEmpty
                            ? Text(
                          'No patients assigned',
                          style: AppText.body.copyWith(
                              color: AppColors.textSecondary),
                        )
                            : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPatientId,
                            isExpanded: true,
                            hint: Text(
                              'Choose patient',
                              style: AppText.muted,
                            ),
                            isDense: true,
                            items: _patients.map((p) {
                              return DropdownMenuItem<String>(
                                value: p["patientId"],
                                child: Text(
                                  p["name"] ?? p["patientId"],
                                  style: AppText.body,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPatientId = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FILE PICKER
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 40, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text(
                      _file == null ? 'Tap to upload file' : 'Tap to change file',
                      style: AppText.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('PDF, JPG, PNG up to 5MB', style: AppText.muted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // FILE PREVIEW
            if (_file != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_getFileIcon(_file!.extension),
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _file!.name,
                        style: AppText.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _file = null),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // SEND BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReady ? _sendReport : null,
                child: _loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Send Report'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? ext) {
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['jpg', 'jpeg', 'png'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }
}

// Reusable info card widget
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.loading,
    required this.value,
    this.isError = false,
  });

  final IconData icon;
  final String   label;
  final bool     loading;
  final String   value;
  final bool     isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.muted),
                const SizedBox(height: 2),
                loading
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  value,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isError ? Colors.red : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}