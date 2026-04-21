import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _loading = true; _error = null; });

    final data = await AuthService.getReports();
    if (!mounted) return;

    if (data["success"] == true) {
      setState(() {
        _reports = data["reports"] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error   = data["message"] ?? "Failed to load reports";
        _loading = false;
      });
    }
  }

  Future<void> _openReport(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: AppText.muted))
          : _reports.isEmpty
          ? const Center(child: Text('No reports found'))
          : RefreshIndicator(
        onRefresh: _loadReports,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = _reports[index];
            return _ReportCard(
              report: report,
              onOpen: () => _openReport(report["url"]),
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onOpen});

  final Map<String, dynamic> report;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final createdAt = report["createdAt"] != null
        ? DateTime.tryParse(report["createdAt"])
        : null;

    final dateStr = createdAt != null
        ? "${createdAt.day}/${createdAt.month}/${createdAt.year}"
        : "—";

    final isPdf = (report["docType"] ?? "").toString().toUpperCase() == "PDF";

    final therapistDisplay = report["therapistName"] ?? report["therapistId"] ?? "—";
    final patientDisplay   = report["patientName"]   ?? report["patientId"]   ?? "—";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientDisplay,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text("Therapist: $therapistDisplay", style: AppText.muted),
                Text("Date: $dateStr",               style: AppText.muted),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: AppColors.primary),
            tooltip: 'Open report',
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}