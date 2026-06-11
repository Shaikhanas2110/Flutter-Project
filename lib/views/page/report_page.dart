import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

List<Subscription> subscriptions = [];
bool isLoading = true;

class _ReportsScreenState extends State<ReportsScreen> {
  // ── Brand colors ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _card = Color(0xFF131929);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _indigoLight = Color(0xFF818CF8);
  static const Color _border = Color(0x1AFFFFFF);
  static const Color _green = Color(0xFF22C55E);
  static const Color _errorRed = Color(0xFFE24B4A);
  static const Color _amber = Color(0xFFF59E0B);

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
    final barGroups = buildMonthlyBars(monthlyTotals, context);
    final maxY = calculateMaxY(monthlyTotals);
    final categoryData = calculateCategorySpending(subscriptions);
    final total = getTotalSpending(categoryData);
    final thisMonthCost = getThisMonthSpending(subscriptions);
    final lastMonthCost = getLastMonthSpending(subscriptions);
    final difference = thisMonthCost - lastMonthCost;
    final percentageChange = lastMonthCost == 0
        ? 0.0
        : (difference / lastMonthCost) * 100;
    final isUp = percentageChange >= 0;

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentPage: DrawerPage.reports),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.06)),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_indigo, _cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.donut_small_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Substrata',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 24,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: _indigo, strokeWidth: 2),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page heading ──
                    Text(
                      'Reports',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your spending at a glance',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── This month vs last month cards ──
                    Row(
                      children: [
                        // This month
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _card,
                              border: Border.all(color: _border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'THIS MONTH',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        color: Colors.white.withOpacity(0.35),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUp
                                            ? _errorRed.withOpacity(0.12)
                                            : _green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isUp
                                                ? Icons.arrow_upward_rounded
                                                : Icons.arrow_downward_rounded,
                                            size: 10,
                                            color: isUp ? _errorRed : _green,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${percentageChange.abs().toStringAsFixed(1)}%',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              color: isUp ? _errorRed : _green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '₹${thisMonthCost.toStringAsFixed(0)}',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isUp
                                      ? 'Up from last month'
                                      : 'Down from last month',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Last month
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _card,
                              border: Border.all(color: _border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LAST MONTH',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: Colors.white.withOpacity(0.35),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '₹${lastMonthCost.toStringAsFixed(0)}',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Previous period',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Spending trends chart ──
                    Text(
                      'Spending Trends',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monthly breakdown across the year',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      height: 220,
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      decoration: BoxDecoration(
                        color: _card,
                        border: Border.all(color: _border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BarChart(
                        BarChartData(
                          minY: 0,
                          maxY: maxY,
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: barGroups,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 4,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.white.withOpacity(0.05),
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
                                reservedSize: 28,
                                getTitlesWidget: (value, _) {
                                  const months = [
                                    'J',
                                    'F',
                                    'M',
                                    'A',
                                    'M',
                                    'J',
                                    'J',
                                    'A',
                                    'S',
                                    'O',
                                    'N',
                                    'D',
                                  ];
                                  final i = value.toInt();
                                  if (i < 0 || i >= months.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final isCurrentMonth =
                                      i == DateTime.now().month - 1;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      months[i],
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: isCurrentMonth
                                            ? _indigoLight
                                            : Colors.white.withOpacity(0.3),
                                        fontWeight: isCurrentMonth
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '₹${rod.toY.toStringAsFixed(0)}',
                                      GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── By category ──
                    Text(
                      'By Category',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Where your money goes',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (categoryData.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: _card,
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pie_chart_outline_rounded,
                              size: 32,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No category data yet',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _card,
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: categoryData.entries.map((entry) {
                            final pct = entry.value / total;
                            return _categoryRow(
                              title: entry.key,
                              amount: entry.value,
                              percentage: pct,
                              color: _categoryColor(entry.key),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _categoryRow({
    required String title,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 64,
                child: Text(
                  '₹${amount.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.07),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

List<BarChartGroupData> buildMonthlyBars(
  Map<int, double> monthlyTotals,
  BuildContext context,
) {
  final currentMonth = DateTime.now().month - 1;

  return monthlyTotals.entries.map((entry) {
    final isCurrentMonth = entry.key == currentMonth;
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value,
          width: 10,
          borderRadius: BorderRadius.circular(5),
          gradient: isCurrentMonth
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
              : null,
          color: isCurrentMonth ? null : Colors.white.withOpacity(0.12),
        ),
      ],
    );
  }).toList();
}

Map<int, double> calculateMonthlySpending(List<Subscription> subs) {
  final Map<int, double> monthlyTotals = {for (int i = 0; i < 12; i++) i: 0.0};
  for (final sub in subs) {
    final date = sub.nextPaymentDate;
    if (date == null) continue;
    final monthIndex = date.month - 1;
    monthlyTotals[monthIndex] = monthlyTotals[monthIndex]! + sub.cost;
  }
  return monthlyTotals;
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
  // Sort by value descending
  final sorted = Map.fromEntries(
    categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
  return sorted;
}

double getTotalSpending(Map<String, double> data) =>
    data.values.fold(0, (a, b) => a + b);

double getThisMonthSpending(List<Subscription> subs) {
  final now = DateTime.now();
  return subs
      .where(
        (s) =>
            s.nextPaymentDate != null &&
            s.nextPaymentDate!.month == now.month &&
            s.nextPaymentDate!.year == now.year,
      )
      .fold(0.0, (sum, s) => sum + s.cost);
}

double getLastMonthSpending(List<Subscription> subs) {
  final now = DateTime.now();
  final lastMonth = now.month == 1 ? 12 : now.month - 1;
  final year = now.month == 1 ? now.year - 1 : now.year;
  return subs
      .where(
        (s) =>
            s.nextPaymentDate != null &&
            s.nextPaymentDate!.month == lastMonth &&
            s.nextPaymentDate!.year == year,
      )
      .fold(0.0, (sum, s) => sum + s.cost);
}

Color _categoryColor(String category) {
  switch (category) {
    case "Streaming":
      return const Color(0xFFE24B4A);
    case "Productivity":
      return const Color(0xFF6366F1);
    case "Education":
      return const Color(0xFF22C55E);
    case "Music":
      return const Color(0xFFF59E0B);
    case "Storage":
      return const Color(0xFF06B6D4);
    case "Design":
      return const Color(0xFFEC4899);
    case "Development":
      return const Color(0xFF818CF8);
    case "News":
      return const Color(0xFFF97316);
    case "Fitness":
      return const Color(0xFFA855F7);
    default:
      return const Color(0xFF6B7280);
  }
}
