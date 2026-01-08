import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/payment_buckets.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

List<Subscription> subscriptions = [];
bool isLoading = true;

class _PaymentScreenState extends State<PaymentScreen> {
  Future<void> fetchSubscriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user.uid)
        .child("subscriptions");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;

      final List<Subscription> loadedSubs = [];

      data.forEach((key, value) {
        DateTime? parsedDate;

        final rawDate = value["nextPaymentDate"];

        if (rawDate != null && rawDate is String && rawDate.isNotEmpty) {
          try {
            parsedDate = DateTime.parse(rawDate);
          } catch (e) {
            debugPrint("Invalid date for $key → $rawDate");
          }
        }

        loadedSubs.add(
          Subscription(
            id: key,
            serviceName: value["serviceName"] ?? "",
            billingCycle: value["billingCycle"] ?? "",
            cost: (value["cost"] as num).toDouble(),
            category: value["category"] ?? "",
            nextPaymentDate: parsedDate, // ✅ SAFE
          ),
        );
      });

      setState(() {
        subscriptions = loadedSubs;

        isLoading = false;
      });
    } else {
      setState(() {
        subscriptions = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    final buckets = splitSubscriptionsByDate(subscriptions);
    final thisWeekSubs = buckets.thisWeek;
    final thisMonthSubs = buckets.thisMonth;
    final nextMonthSubs = buckets.nextMonth;
    final totalThisMonth = totalDueThisMonth(subscriptions);

    return Scaffold(
      backgroundColor: Color(0xFF000000),

      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 35),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.grey,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Color(0xFF1f1f1f)),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wallet_rounded, size: 35, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('SubTracker', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      drawer: const AppDrawer(currentPage: DrawerPage.payments),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //----------------SUMMARY CARD-----------------
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF1f1f1f),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFF000000),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.timer,
                                color: Colors.red,
                                size: 35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  color: Colors.white,
                                  size: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                Text(
                                  "${totalThisMonth.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              'due this month',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                //----------------THIS WEEK DUE-----------------
                SizedBox(height: 30),
                Text(
                  'This Week'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (buckets.thisWeek.isEmpty)
                  Center(child: emptyText('No subscriptions due this week'))
                else
                  ...buckets.thisWeek.map(
                    (sub) => subscriptionTile(
                      sub.serviceName,
                      sub.category,
                      '₹${sub.cost.toStringAsFixed(2)}',
                      _categoryColor(sub.category), // color based on category
                      sub.nextPaymentDate,
                    ),
                  ),

                //----------------NEXT WEEK DUE-----------------
                SizedBox(height: 30),
                Text(
                  'This Month'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (buckets.thisMonth.isEmpty)
                  Center(child: emptyText('No subscriptions due this month'))
                else
                  ...buckets.thisMonth.map(
                    (sub) => subscriptionTile(
                      sub.serviceName,
                      sub.category,
                      '₹${sub.cost.toStringAsFixed(2)}',
                      _categoryColor(sub.category), // color based on category
                      sub.nextPaymentDate,
                    ),
                  ),

                //----------------NEXT MONTH DUE-----------------
                SizedBox(height: 30),
                Text(
                  'Next MONTH'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (buckets.nextMonth.isEmpty)
                  Center(child: emptyText('No subscriptions due next month'))
                else
                  ...buckets.nextMonth.map(
                    (sub) => subscriptionTile(
                      sub.serviceName,
                      sub.category,
                      '₹${sub.cost.toStringAsFixed(2)}',
                      _categoryColor(sub.category), // color based on category
                      sub.nextPaymentDate,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget subscriptionTile(
  String title,
  String subtitle,
  String price,
  Color color,
  DateTime? date,
) {
  final iconData = _iconForCategory(subtitle); // Get icon by category
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFF1f1f1f),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Color(0xFF000000),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(iconData, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4),
              if (date != null)
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

PaymentBuckets splitSubscriptionsByDate(List<Subscription> subs) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final endOfWeek = today.add(Duration(days: 7 - today.weekday));

  final endOfMonth = DateTime(today.year, today.month + 1, 0);
  final startOfNextMonth = DateTime(today.year, today.month + 1, 1);
  final endOfNextMonth = DateTime(today.year, today.month + 2, 0);

  final thisWeek = <Subscription>[];
  final thisMonth = <Subscription>[];
  final nextMonth = <Subscription>[];

  for (final sub in subs) {
    final date = sub.nextPaymentDate;
    if (date == null) continue;

    final paymentDate = DateTime(date.year, date.month, date.day);

    if (paymentDate.isBefore(today)) continue;

    if (!paymentDate.isAfter(endOfWeek)) {
      thisWeek.add(sub);
    } else if (!paymentDate.isAfter(endOfMonth)) {
      thisMonth.add(sub);
    } else if (!paymentDate.isBefore(startOfNextMonth) &&
        !paymentDate.isAfter(endOfNextMonth)) {
      nextMonth.add(sub);
    }
  }

  return PaymentBuckets(
    thisWeek: thisWeek,
    thisMonth: thisMonth,
    nextMonth: nextMonth,
  );
}

double totalDueThisMonth(List<Subscription> subs) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);

  double total = 0;

  for (final sub in subs) {
    final date = sub.nextPaymentDate;
    if (date == null) continue;

    if (!date.isBefore(start) && !date.isAfter(end)) {
      total += sub.cost;
    }
  }

  return total;
}

Color _categoryColor(String category) {
  switch (category) {
    case "Streaming":
      return Colors.redAccent;
    case "Productivity":
      return Colors.blueAccent;
    case "Education":
      return Colors.greenAccent;
    case "Music":
      return Colors.amberAccent;
    case "Storage":
      return Colors.limeAccent;
    case "Design":
      return Colors.pinkAccent;
    case "Development":
      return Colors.indigoAccent;
    case "News":
      return Colors.deepOrangeAccent;
    case "Fitness":
      return Colors.purpleAccent;
    default:
      return Colors.grey;
  }
}

IconData _iconForCategory(String category) {
  switch (category) {
    case "Streaming":
      return Icons.tv;
    case "Productivity":
      return Icons.design_services_outlined;
    case "Education":
      return Icons.school_outlined;
    case "Music":
      return Icons.headphones_outlined;
    case "Storage":
      return Icons.cloud_outlined;
    case "Design":
      return Icons.brush_outlined;
    case "Development":
      return Icons.developer_mode_outlined;
    case "News":
      return Icons.newspaper_outlined;
    case "Fitness":
      return Icons.newspaper_outlined;
    default:
      return Icons.subscriptions;
  }
}

Widget emptyText(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );
}
