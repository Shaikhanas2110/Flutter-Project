import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

List<Subscription> subscriptions = [];
bool isLoading = true;

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user.uid)
        .child("subscriptions");

    final snapshot = await ref.get();

    if (!snapshot.exists) {
      setState(() => isLoading = false);
      return;
    }

    final Map data = snapshot.value as Map;

    final List<Subscription> loaded = [];

    data.forEach((key, value) {
      try {
        loaded.add(
          Subscription(
            id: key,
            serviceName: value["serviceName"] ?? "",
            category: value["category"] ?? "",
            billingCycle: value["billingCycle"] ?? "",
            cost: (value["cost"] as num).toDouble(),
            nextPaymentDate: DateTime.parse(value["nextPaymentDate"]),
          ),
        );
      } catch (_) {}
    });

    setState(() {
      subscriptions = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTotals = calculateMonthlySpending(subscriptions);
    final barGroups = buildMonthlyBars(monthlyTotals);
    final maxY = calculateMaxY(monthlyTotals);
    final categoryData = calculateCategorySpending(subscriptions);
    final total = getTotalSpending(categoryData);
    final thisMonthCost = getThisMonthSpending(subscriptions);
    final lastMonthCost = getLastMonthSpending(subscriptions);
    final difference = thisMonthCost - lastMonthCost;
    final percentageChange = lastMonthCost == 0
        ? 0
        : (difference / lastMonthCost) * 100;

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
      drawer: const AppDrawer(currentPage: DrawerPage.reports),
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
                          Icons.trending_up,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        title: percentageChange >= 0
                            ? '+${percentageChange.toStringAsFixed(1)}% from last month'
                            : '${percentageChange.toStringAsFixed(1)}% from last month',
                        value: '₹${thisMonthCost.toStringAsFixed(0)}',
                        color: percentageChange >= 0
                            ? Color(0xFF16a34a)
                            : Colors.redAccent,
                        boxColor: Color(0xFFdcfce7),
                        subTitle: "THIS MONTH",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: summaryCard(
                        context,
                        icon: Icon(
                          Icons.history,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        title: 'Last month spending',
                        value: '₹${lastMonthCost.toStringAsFixed(0)}',
                        color: Colors.blueAccent,
                        boxColor: Color(0xFFdbeafe),
                        subTitle: "LAST MONTH"
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Spending Trends',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,

                      gridData: FlGridData(
                        show: false,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          strokeWidth: 1,
                        ),
                      ),

                      borderData: FlBorderData(show: false),

                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec',
                              ];

                              final index = value.toInt();
                              if (index < 0 || index >= months.length) {
                                return const SizedBox.shrink();
                              }

                              return Text(
                                months[index],
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
                Text(
                  'By Category',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: categoryData.entries.map((entry) {
                        final percentage = entry.value / total;

                        return categoryRow(
                          context,
                          title: entry.key,
                          amount: entry.value,
                          percentage: percentage,
                          color: _categoryColor(entry.key),
                        );
                      }).toList(),
                    ),
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

Widget summaryCard(
  BuildContext context, {
  required Icon icon,
  required String title,
  required String value,
  required Color color,
  required Color boxColor,
  required String subTitle,
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
        Row(
          children: [
            Text(
              subTitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(icon.icon, color: icon.color),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

BarChartGroupData bar(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 12,
        borderRadius: BorderRadius.circular(6),
        color: Colors.blueAccent,
      ),
    ],
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

Map<int, double> calculateMonthlySpending(List<Subscription> subs) {
  final Map<int, double> monthlyTotals = {for (int i = 0; i < 12; i++) i: 0.0};

  for (final sub in subs) {
    final date = sub.nextPaymentDate;
    if (date == null) continue;

    final monthIndex = date.month - 1; // 0-based
    monthlyTotals[monthIndex] = monthlyTotals[monthIndex]! + sub.cost;
  }

  return monthlyTotals;
}

List<BarChartGroupData> buildMonthlyBars(Map<int, double> monthlyTotals) {
  return monthlyTotals.entries.map((entry) {
    return bar(entry.key, entry.value);
  }).toList();
}

double calculateMaxY(Map<int, double> data) {
  final max = data.values.fold(0.0, (a, b) => a > b ? a : b);
  return max == 0 ? 200 : max + 50;
}

Map<String, double> calculateCategorySpending(List<Subscription> subs) {
  final Map<String, double> categoryTotals = {};

  for (final sub in subs) {
    categoryTotals[sub.category] =
        (categoryTotals[sub.category] ?? 0) + sub.cost;
  }

  return categoryTotals;
}

double getTotalSpending(Map<String, double> data) {
  return data.values.fold(0, (a, b) => a + b);
}

Widget categoryRow(
  BuildContext context, {
  required String title,
  required double amount,
  required double percentage,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        Icon(Icons.circle, size: 15, color: color),
        const SizedBox(width: 8),

        SizedBox(
          width: 110,
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: Colors.white12,
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 60,
          child: Text(
            '₹${amount.toStringAsFixed(1)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    ),
  );
}

double getThisMonthSpending(List<Subscription> subs) {
  final now = DateTime.now();

  return subs
      .where((sub) {
        if (sub.nextPaymentDate == null) return false;

        final d = sub.nextPaymentDate!;
        return d.month == now.month && d.year == now.year;
      })
      .fold(0.0, (sum, sub) => sum + sub.cost);
}

double getLastMonthSpending(List<Subscription> subs) {
  final now = DateTime.now();

  final lastMonth = now.month == 1 ? 12 : now.month - 1;
  final year = now.month == 1 ? now.year - 1 : now.year;

  return subs
      .where((sub) {
        if (sub.nextPaymentDate == null) return false;

        final d = sub.nextPaymentDate!;
        return d.month == lastMonth && d.year == year;
      })
      .fold(0.0, (sum, sub) => sum + sub.cost);
}
