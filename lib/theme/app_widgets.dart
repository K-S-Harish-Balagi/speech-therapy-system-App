import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─── Auth layout ──────────────────────────────────────────────────────────────
// Each screen owns its Scaffold. AuthLayout only provides the responsive
// card wrapper inside the body — so AppBar / back buttons work on mobile,
// and a card with shadow appears on wide (web/tablet) layouts.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 20 : 0,
            vertical: isWide ? 40 : 0,
          ),
          child: Container(
            width: isWide ? 420 : double.infinity,
            // Mobile: flush full-screen card, no shadow
            // Web / tablet: elevated card with border radius
            padding: EdgeInsets.all(isWide ? 28 : 24),
            decoration: isWide
                ? BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            )
                : const BoxDecoration(color: AppColors.surface),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo mark — shown only on wide layout
                  if (isWide) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hearing,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(title, style: AppText.screenTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: AppText.muted),
                  ],
                  const SizedBox(height: 28),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App button ───────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isOutlined = variant == AppButtonVariant.outlined;
    final isDanger   = variant == AppButtonVariant.danger;

    final bg = isDanger
        ? AppColors.danger
        : isOutlined
        ? Colors.transparent
        : AppColors.primary;

    final fg = isOutlined ? AppColors.primary : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: isOutlined
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(strokeWidth: 2, color: fg),
        )
            : icon != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        )
            : Text(label),
      ),
    );
  }
}

enum AppButtonVariant { primary, outlined, danger }

// ─── Spacing ──────────────────────────────────────────────────────────────────
const kFieldGap   = SizedBox(height: 16);
const kSectionGap = SizedBox(height: 24);

// ─── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text.toUpperCase(), style: AppText.sectionLabel),
  );
}

// ─── Divider with label ───────────────────────────────────────────────────────
class LabelDivider extends StatelessWidget {
  const LabelDivider(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: AppColors.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text, style: AppText.muted),
      ),
      const Expanded(child: Divider(color: AppColors.border)),
    ],
  );
}

// ─── Info row ─────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style:
              AppText.body.copyWith(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value ?? '—',
            style: AppText.body.copyWith(
              color: value != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}