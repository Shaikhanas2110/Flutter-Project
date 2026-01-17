import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'notification_service.dart';

class SubscriptionNotificationChecker {
  static Future<void> checkExpiringSubscriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref().child("users").child(user.uid);

    final notifySnapshot = await ref.child("notify").get();
    final notifyEnabled = notifySnapshot.exists && notifySnapshot.value == true;
    if (!notifyEnabled) return;

    final subSnapshot = await ref.child("subscriptions").get();
    if (!subSnapshot.exists) return;

    final Map subscriptions = Map<String, dynamic>.from(
      subSnapshot.value as Map,
    );
    final now = DateTime.now();

    for (final entry in subscriptions.entries) {
      final sub = entry.value;
      final String? name = sub['serviceName'];
      final String? dateStr = sub['nextPaymentDate'];

      if (name == null || dateStr == null) continue;

      final DateTime? paymentDate = DateTime.tryParse(dateStr);

      if (paymentDate == null) return;

      final int daysLeft = paymentDate.difference(now).inDays;

      if (daysLeft >= 0 && daysLeft <= 3) {
        await NotificationService.showNotification(
          title: "Subscription Expiring Soon",
          body: "$name expires in $daysLeft day(s)",
        );
      }
    }
  }
}
