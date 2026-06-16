import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // ── Brand colors (Matched from ReportsScreen & SettingsScreen) ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _green = Color(0xFF22C55E);
  static const Color _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.6)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.06)),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_indigo, _cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'SubTracker',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Heading ──
              Text(
                'Contact Support',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Have questions or feedback? We'd love to hear from you",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),

              const SizedBox(height: 24),

              // ── Support Channels ──
              summaryCard(
                context,
                icon: const Icon(Icons.email_outlined, color: _green, size: 24),
                title: 'support@subtracker.com',
                value: 'Email',
                iconBgColor: _green.withOpacity(0.1),
              ),

              const SizedBox(height: 14),

              summaryCard(
                context,
                icon: const Icon(
                  Icons.phone_outlined,
                  color: _indigo,
                  size: 24,
                ),
                title: '+91 9265-88-6444',
                value: 'Phone',
                iconBgColor: _indigo.withOpacity(0.1),
              ),

              const SizedBox(height: 14),

              summaryCard(
                context,
                icon: const Icon(
                  Icons.location_on_outlined,
                  color: _amber,
                  size: 24,
                ),
                title: 'Ahmedabad',
                value: 'Office',
                iconBgColor: _amber.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Redesigned Card Component ───────────────────────────────────────────────

Widget summaryCard(
  BuildContext context, {
  required Icon icon,
  required String title,
  required String value,
  required Color iconBgColor,
}) {
  const Color cardColor = Color(0xFF131929);
  const Color borderColor = Color(0x1AFFFFFF);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardColor,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon.icon, color: icon.color, size: icon.size),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white.withOpacity(0.15),
          size: 14,
        ),
      ],
    ),
  );
}
