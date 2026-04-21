import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? _therapistId;
  String? _therapistName;
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _loadingTherapist = true;
  bool _loadingSlots = false;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _fetchTherapist();
  }

  Future<void> _fetchTherapist() async {
    try {
      final data = await AuthService.getMyTherapist();
      if (data["success"] == true) {
        setState(() {
          _therapistId   = data["therapistId"];
          _therapistName = data["name"];
        });
      } else {
        _showSnack(data["message"] ?? "No therapist assigned",
            error: true);
      }
    } catch (_) {
      _showSnack("Failed to load therapist", error: true);
    } finally {
      setState(() => _loadingTherapist = false);
    }
  }

  Future<void> _fetchSlots(DateTime date) async {
    if (_therapistId == null) return;
    setState(() {
      _loadingSlots   = true;
      _availableSlots = [];
      _selectedSlot   = null;
    });

    try {
      final data = await AuthService.getAvailableSlots(
        therapistId: _therapistId!,
        date: _formatDate(date),
      );
      if (data["success"] == true) {
        setState(() =>
        _availableSlots = List<String>.from(data["available"]));
        if (_availableSlots.isEmpty) {
          _showSnack("No slots available on this day");
        }
      }
    } catch (_) {
      _showSnack("Failed to load slots", error: true);
    } finally {
      setState(() => _loadingSlots = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 1)),
      firstDate: today.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _fetchSlots(picked);
    }
  }

  Future<void> _book() async {
    if (_selectedDate == null || _selectedSlot == null) {
      _showSnack("Select a date and time slot");
      return;
    }

    setState(() => _booking = true);
    try {
      final data = await AuthService.bookAppointment(
        date:     _formatDate(_selectedDate!),
        timeSlot: _selectedSlot!,
      );
      _showSnack(
        data["message"] ?? "Something went wrong",
        error: data["success"] != true,
      );
      if (data["success"] == true) {
        setState(() {
          _selectedDate   = null;
          _selectedSlot   = null;
          _availableSlots = [];
        });
      }
    } catch (_) {
      _showSnack("Booking failed", error: true);
    } finally {
      setState(() => _booking = false);
    }
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loadingTherapist
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? (w - 460) / 2 : 20,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Therapist card ──────────────────────────────
            Container(
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
                    child: Icon(Icons.person_outline,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your therapist', style: AppText.muted),
                      const SizedBox(height: 2),
                      Text(
                        _therapistName ?? "Not assigned",
                        style: AppText.body.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Date picker ─────────────────────────────────
            Text('Select date', style: AppText.sectionLabel),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Tap to choose a date"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: AppText.body.copyWith(
                        color: _selectedDate == null
                            ? AppColors.textSecondary
                            : null,
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Slot picker ─────────────────────────────────
            if (_selectedDate != null) ...[
              Text('Select time slot',
                  style: AppText.sectionLabel),
              const SizedBox(height: 8),
              if (_loadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_busy,
                          color: AppColors.textSecondary,
                          size: 20),
                      const SizedBox(width: 10),
                      Text('No slots available on this day',
                          style: AppText.muted),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableSlots.map((slot) {
                    final selected = _selectedSlot == slot;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedSlot = slot),
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          slot,
                          style: AppText.body.copyWith(
                            color: selected
                                ? Colors.white
                                : null,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),
            ],

            // ── Book button ─────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (_booking ||
                    _selectedDate == null ||
                    _selectedSlot == null)
                    ? null
                    : _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _booking
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}