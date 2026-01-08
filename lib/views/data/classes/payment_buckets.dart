import 'package:my_app/views/data/classes/subscriptions.dart';

class PaymentBuckets {
  final List<Subscription> thisWeek;
  final List<Subscription> thisMonth;
  final List<Subscription> nextMonth;

  PaymentBuckets({
    required this.thisWeek,
    required this.thisMonth,
    required this.nextMonth,
  });
}