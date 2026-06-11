import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSubscriptionDialog extends StatefulWidget {
  final VoidCallback onSubscriptionAdded;
  const AddSubscriptionDialog({super.key, required this.onSubscriptionAdded});

  @override
  State<AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController costCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  String billingCycle = "Monthly";
  String category = "Streaming";
  String recurring = "Yes";
  bool _isSubmitting = false;

  // ── Brand colors ──
  static const Color _bg = Color(0xFF0F1424);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _errorRed = Color(0xFFE24B4A);

  @override
  void dispose() {
    serviceCtrl.dispose();
    costCtrl.dispose();
    dateCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar ──
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW SUBSCRIPTION',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: _indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add subscription',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Service Name ──
              _label('Service name'),
              _textField(
                controller: serviceCtrl,
                hint: 'e.g. Netflix, Spotify',
                icon: Icons.apps_rounded,
                validator: (v) =>
                    v!.isEmpty ? 'Service name is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Cost + Billing Cycle ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Cost (₹)'),
                        _textField(
                          controller: costCtrl,
                          hint: '0.00',
                          icon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Cost required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Billing cycle'),
                        _dropdown(
                          value: billingCycle,
                          items: ['Monthly', 'Yearly', 'Quaterly', 'Weekly'],
                          onChanged: (v) => setState(() => billingCycle = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Category + Recurring ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Category'),
                        _dropdown(
                          value: category,
                          items: [
                            'Streaming',
                            'Productivity',
                            'Education',
                            'Music',
                            'Design',
                            'Development',
                            'Fitness',
                            'News',
                            'Storage',
                            'Other',
                          ],
                          onChanged: (v) => setState(() => category = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Recurring?'),
                        _dropdown(
                          value: recurring,
                          items: ['Yes', 'No'],
                          onChanged: (v) => setState(() => recurring = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Next Payment Date ──
              _label('Next payment date'),
              _textField(
                controller: dateCtrl,
                hint: 'Select a date',
                icon: Icons.calendar_month_outlined,
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => v!.isEmpty ? 'Date is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Description ──
              _label('Description (optional)'),
              _textField(
                controller: descCtrl,
                hint: 'Brief description or plan details...',
                maxLines: 2,
              ),

              const SizedBox(height: 28),

              // ── Submit button ──
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? null
                        : const LinearGradient(
                            colors: [_indigo, _cyan],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: _isSubmitting
                        ? Colors.white.withOpacity(0.05)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          )
                        : Text(
                            'Add subscription',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Cancel ──
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Firebase ──────────────────────────────────────────────────────────────

  Future<void> addSubscriptionToFirebase({
    required String serviceName,
    required double cost,
    required String billingCycle,
    required String category,
    required bool recurring,
    required String nextPaymentDate,
    String description = "",
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user.uid)
        .child("subscriptions")
        .push();

    await ref.set({
      "serviceName": serviceName,
      "cost": cost,
      "billingCycle": billingCycle,
      "category": category,
      "recurring": recurring,
      "nextPaymentDate": nextPaymentDate,
      "description": description,
      "createdAt": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _indigo,
              onPrimary: Colors.white,
              surface: Color(0xFF131929),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F1424),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateCtrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await addSubscriptionToFirebase(
        serviceName: serviceCtrl.text.trim(),
        cost: double.parse(costCtrl.text),
        billingCycle: billingCycle,
        category: category,
        recurring: recurring == "Yes",
        nextPaymentDate: dateCtrl.text,
        description: descCtrl.text.trim(),
      );
      widget.onSubscriptionAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add: $e',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: _errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.5),
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: Colors.white.withOpacity(0.2),
          fontSize: 14,
        ),
        suffixIcon: icon != null
            ? Icon(icon, color: Colors.white.withOpacity(0.25), size: 18)
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _indigo.withOpacity(0.7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: _errorRed, fontSize: 11),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: const Color(0xFF131929),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white.withOpacity(0.3),
        size: 18,
      ),
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _indigo.withOpacity(0.7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: _errorRed, fontSize: 11),
      ),
    );
  }
}
