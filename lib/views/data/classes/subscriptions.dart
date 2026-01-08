class Subscription {
  final String id;
  final String serviceName;
  final String billingCycle;
  final double cost;
  final String category;
  final DateTime? nextPaymentDate;

  Subscription({
    required this.id,
    required this.serviceName,
    required this.billingCycle,
    required this.cost,
    required this.category,
    required this.nextPaymentDate,
  });
}
