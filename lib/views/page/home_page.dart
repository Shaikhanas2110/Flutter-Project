import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import 'package:my_app/views/widgets/form_widget.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

List<Subscription> subscriptions = [];
bool isLoading = true;
int nearestPaymentDays = -1;

enum SubscriptionFilter {
  priceLowToHigh,
  priceHighToLow,
  nameAToZ,
  nameZToA,
  upcoming,
  past,
}

class HomeScreenState extends State<HomeScreen> {
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

        // 🔥 EXTRACT DATES HERE
        final dates = subscriptions
            .where((s) => s.nextPaymentDate != null)
            .map((s) => s.nextPaymentDate!.toIso8601String())
            .toList();

        nearestPaymentDays = getNearestPaymentDays(dates);

        isLoading = false;
      });
    } else {
      setState(() {
        subscriptions = [];
        isLoading = false;
      });
    }
  }

  SubscriptionFilter? activeFilter;


  List<Subscription> get filteredSubscriptions {
    final DateTime today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    List<Subscription> list = subscriptions.where((s) {
      if(s.nextPaymentDate == null) return true;
      return !s.nextPaymentDate!.isBefore(today);
    }).toList();
  
    switch (activeFilter) {
      case SubscriptionFilter.past:
        list = subscriptions.where((s) {
          return s.nextPaymentDate != null && s.nextPaymentDate!.isBefore(today);
        }).toList();
        break;
      
      case SubscriptionFilter.priceLowToHigh:
        list.sort((a,b) => a.cost.compareTo(b.cost));
        break;

      case SubscriptionFilter.priceHighToLow:
        list.sort((a,b) => b.cost.compareTo(a.cost));
        break;

      case SubscriptionFilter.nameAToZ:
        list.sort((a,b) => a.serviceName.compareTo(b.serviceName));
        break;

      case SubscriptionFilter.nameZToA:
        list.sort((a,b) => b.serviceName.compareTo(a.serviceName));
        break;

      case SubscriptionFilter.upcoming:
        //Handle By Default
        break;

      default:
        break;
    }

    return list;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterTile("Price: Low → High", SubscriptionFilter.priceLowToHigh),
            _filterTile("Price: High → Low", SubscriptionFilter.priceHighToLow),
            _filterTile("Name: A → Z", SubscriptionFilter.nameAToZ),
            _filterTile("Name: Z → A", SubscriptionFilter.nameZToA),
            _filterTile("Upcoming Payments", SubscriptionFilter.upcoming),
            _filterTile("Past Subscriptions", SubscriptionFilter.past),
            ListTile(
              leading: Icon(Icons.clear),
              title: Text("Clear Filter"),
              onTap: () {
                setState(() => activeFilter = null);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _filterTile(String title, SubscriptionFilter filter) {
    return ListTile(
      title: Text(title),
      trailing: activeFilter == filter
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() => activeFilter = filter);
        Navigator.pop(context);
      },
    );
  }

  Widget buildSubscriptionsList(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ THIS IS THE KEY LINE
    final list = filteredSubscriptions;

    if (list.isEmpty) {
      return Center(
        child: Text(
          "No subscriptions found",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length, // ✅ USE FILTERED LIST LENGTH
      itemBuilder: (context, index) {
        final sub = list[index]; // ✅ USE FILTERED LIST ITEM

        return subscriptionTile(
          context,
          sub.serviceName,
          sub.billingCycle,
          "₹${sub.cost.toStringAsFixed(0)}",
          _categoryColor(sub.category),
          sub.category,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 35),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
      drawer: const AppDrawer(currentPage: DrawerPage.subscriptions),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: summaryCard(
                        context,
                        icon: Icon(
                          Icons.currency_rupee,
                          color: const Color(0xFF16a34a),
                          size: 35,
                        ),
                        title: 'Monthly Spend',
                        value: Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              color: const Color(0xFF16a34a),
                            ),
                            Text(
                              calculateMonthlySpend(
                                subscriptions,
                              ).toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16a34a),
                              ),
                            ),
                          ],
                        ),
                        color: Color(0xFF16a34a),
                        boxColor: Color(0xFFdcfce7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: summaryCard(
                        context,
                        icon: Icon(
                          Icons.subscriptions,
                          color: const Color(0xFF3b82f6),
                          size: 35,
                        ),
                        title: 'Active Subs',
                        value: Text(
                          subscriptions.length.toString(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3b82f6),
                          ),
                        ),
                        color: Color(0xFF3b82f6),
                        boxColor: Color(0xFFdbeafe),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: summaryCard(
                        context,
                        icon: Icon(
                          Icons.bar_chart,
                          color: const Color(0xFFea580c),
                          size: 35,
                        ),
                        title: 'Yearly Spend',
                        value: Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              color: const Color(0xFFea580c),
                            ),
                            Text(
                              yearlyCost(
                                subscriptions,
                              ).floorToDouble().toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFea580c),
                              ),
                            ),
                          ],
                        ),
                        color: Color(0xFFea580c),
                        boxColor: Color(0xFFfed7aa),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: summaryCard(
                        context,
                        icon: Icon(
                          Icons.next_plan,
                          color: const Color(0xFF9333ea),
                          size: 35,
                        ),
                        title: 'Next Payment',
                        value: Text(
                          nextPaymentText(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9333ea),
                          ),
                        ),

                        color: Color(0xFF9333ea),
                        boxColor: Color(0xFFf3e8ff),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscriptions',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                buildSubscriptionsList(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            context: context,
            isScrollControlled: true, // Enables full screen dragging
            builder: (context) {
              return DraggableScrollableSheet(
                initialChildSize: 0.7, // Sheet starts at 30% height
                minChildSize: 0.1,
                maxChildSize: 0.8, // Can be dragged up to 80% height
                expand: false, // Ensures it doesn't take full screen initially
                builder: (context, scrollController) => AddSubscriptionDialog(
                  onSubscriptionAdded:
                      fetchSubscriptions, // 🔥 PASS CALLBACK543
                ),
              );
            },
          );
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Text(
          '+',
          style: TextStyle(
            color: Color(0xFF3b82f6),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

Widget summaryCard(
  BuildContext context, {
  required Icon icon,
  required String title,
  required Widget value,
  required Color color,
  required Color boxColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon.icon, color: icon.color, size: icon.size),
        ),
        const SizedBox(height: 12),
        value,
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
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

Widget subscriptionTile(
  BuildContext context,
  String title,
  String subtitle,
  String price,
  Color color,
  String category,
) {
  final iconData = _iconForCategory(category); // Get icon by category

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(iconData, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    ),
  );
}

double calculateMonthlySpend(List<Subscription> subs) {
  double total = 0;

  for (final sub in subs) {
    total += _monthlyCost(sub);
  }

  return total.floorToDouble();
}

double _monthlyCost(Subscription sub) {
  switch (sub.billingCycle.toLowerCase()) {
    case "monthly":
      return sub.cost;

    case "yearly":
      return sub.cost / 12;

    case "weekly":
      return sub.cost * 4.33; // avg weeks per month

    case "quaterly":
      return sub.cost / 3;

    default:
      return 0;
  }
}

int getNearestPaymentDays(List<String> dateStrings) {
  final DateTime today = DateTime.now();
  final DateTime todayDate = DateTime(today.year, today.month, today.day);

  int? nearestDays;

  for (String date in dateStrings) {
    final DateTime paymentDate = DateTime.parse(date);
    final int daysLeft = paymentDate.difference(todayDate).inDays;

    if (daysLeft >= 0) {
      if (nearestDays == null || daysLeft < nearestDays) {
        nearestDays = daysLeft;
      }
    }
  }

  return nearestDays ?? -1; // -1 = no upcoming payments
}

int getDaysUntilPayment(String dateString) {
  final DateTime today = DateTime.now();
  final DateTime paymentDate = DateTime.parse(dateString);

  final Duration diff = paymentDate.difference(
    DateTime(today.year, today.month, today.day),
  );

  return diff.inDays;
}

double yearlyCost(List<Subscription> subs) {
  return calculateMonthlySpend(subs) * 12.00;
}

String nextPaymentText() {
  if (nearestPaymentDays == -1) return "No upcoming";
  if (nearestPaymentDays == 0) return "Today";
  if (nearestPaymentDays == 1) return "Tomorrow";
  return "$nearestPaymentDays days";
}
