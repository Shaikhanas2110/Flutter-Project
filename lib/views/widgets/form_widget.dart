import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Subscription",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _label("Service Name"),
                _textField(
                  controller: serviceCtrl,
                  hint: "e.g., Netflix, Spotify",
                  validator: (v) => v!.isEmpty ? "Service name required" : null,
                ),

                const SizedBox(height: 16),

                /// Cost & Billing
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Cost"),
                          _textField(
                            controller: costCtrl,
                            hint: "0.00",
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? "Cost required" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Billing Cycle"),
                          _dropdown(
                            value: billingCycle,
                            items: ["Monthly", "Yearly", "Quaterly"],
                            onChanged: (v) => setState(() => billingCycle = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Category & Recurring
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _label("Category"),
                          _dropdown(
                            value: category,
                            items: [
                              "Streaming",
                              "Productivity",
                              "Education",
                              "Music",
                              "Design",
                              "Development",
                              "Fitness",
                              "News",
                              "Storage",
                              "Other",
                            ],
                            onChanged: (v) => setState(() => category = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _label("Recurring?"),
                          _dropdown(
                            value: recurring,
                            items: ["Yes", "No"],
                            onChanged: (v) => setState(() => recurring = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Date Picker
                _label("Next Payment Date"),
                _textField(
                  controller: dateCtrl,
                  hint: "Select date",
                  readOnly: true,
                  icon: Icons.calendar_today,
                  onTap: _pickDate,
                  validator: (v) => v!.isEmpty ? "Date required" : null,
                ),

                const SizedBox(height: 16),

                _label("Description (Optional)"),
                _textField(
                  controller: descCtrl,
                  hint: "Brief description or plan details",
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        "Add Subscription",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addSubscriptionToFirebase({
    required String serviceName,
    required double cost,
    required String billingCycle,
    required String category,
    required bool recurring,
    required String nextPaymentDate,
    String description = "",
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final DatabaseReference dbRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(user.uid)
          .child("subscriptions")
          .push(); // auto ID

      await dbRef.set({
        "serviceName": serviceName,
        "cost": cost,
        "billingCycle": billingCycle,
        "category": category,
        "recurring": recurring,
        "nextPaymentDate": nextPaymentDate,
        "description": description,
        "createdAt": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Firebase insert error: $e");
      rethrow;
    }
  }

  /// Date Picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      // ✅ Store ISO date
      final isoDate = picked.toIso8601String().split('T')[0];
      dateCtrl.text = isoDate;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
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
      Navigator.pop(context);
    }
  }

  /// UI Helpers
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, size: 18) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.bold,
      ),
      value: value,
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Please select a category" : null,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}
