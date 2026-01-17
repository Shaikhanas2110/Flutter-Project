import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const PinLockScreen({super.key, required this.onUnlocked});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String enteredPin = '';
  String? correctPin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    correctPin = prefs.getString('app_pin'); // 👈 STORED PIN
    setState(() => loading = false);
  }

  void _onKeyTap(String value) {
    if (enteredPin.length < 4) {
      setState(() => enteredPin += value);
    }

    if (enteredPin.length == 4) {
      if (correctPin == null) {
        widget.onUnlocked();
        return;
      }

      if (enteredPin == correctPin) {
        widget.onUnlocked(); // 🔓 SUCCESS
      } else {
        _resetWithError('Wrong PIN');
      }
    }
  }

  void _resetWithError(String msg) {
    setState(() => enteredPin = '');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onDelete() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter PIN',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),

            // PIN DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: index < enteredPin.length
                        ? Colors.blueAccent
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 80);

              return Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: key == '⌫' ? _onDelete : () => _onKeyTap(key),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    fixedSize: const Size(70, 70),
                    shape: const CircleBorder(),
                  ),
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
