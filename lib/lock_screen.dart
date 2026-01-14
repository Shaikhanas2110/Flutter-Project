import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatelessWidget {
  LockScreen({super.key});

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _unlock(BuildContext context) async {
    final didAuthenticate = await auth.authenticate(
      localizedReason: 'Unlock SubTracker',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      AppLock.of(context)?.didUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.lock_open),
          label: const Text('Unlock'),
          onPressed: () => _unlock(context),
        ),
      ),
    );
  }
}
