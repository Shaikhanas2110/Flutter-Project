import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import 'package:my_app/views/widgets/form_widget.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

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
  // ── Brand colors ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _card = Color(0xFF131929);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _indigoLight = Color(0xFF818CF8);
  static const Color _border = Color(0x1AFFFFFF);

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
            nextPaymentDate: parsedDate,
          ),
        );
      });

      setState(() {
        subscriptions = loadedSubs;
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
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    List<Subscription> list = subscriptions.where((s) {
      if (s.nextPaymentDate == null) return true;
      return !s.nextPaymentDate!.isBefore(today);
    }).toList();

    switch (activeFilter) {
      case SubscriptionFilter.past:
        list = subscriptions.where((s) {
          return s.nextPaymentDate != null &&
              s.nextPaymentDate!.isBefore(today);
        }).toList();
        break;
      case SubscriptionFilter.priceLowToHigh:
        list.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case SubscriptionFilter.priceHighToLow:
        list.sort((a, b) => b.cost.compareTo(a.cost));
        break;
      case SubscriptionFilter.nameAToZ:
        list.sort((a, b) => a.serviceName.compareTo(b.serviceName));
        break;
      case SubscriptionFilter.nameZToA:
        list.sort((a, b) => b.serviceName.compareTo(a.serviceName));
        break;
      default:
        break;
    }
    return list;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort & Filter',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _filterTile(
                "Price: Low → High",
                SubscriptionFilter.priceLowToHigh,
                Icons.arrow_upward_rounded,
              ),
              _filterTile(
                "Price: High → Low",
                SubscriptionFilter.priceHighToLow,
                Icons.arrow_downward_rounded,
              ),
              _filterTile(
                "Name: A → Z",
                SubscriptionFilter.nameAToZ,
                Icons.sort_by_alpha_rounded,
              ),
              _filterTile(
                "Name: Z → A",
                SubscriptionFilter.nameZToA,
                Icons.sort_by_alpha_rounded,
              ),
              _filterTile(
                "Upcoming Payments",
                SubscriptionFilter.upcoming,
                Icons.upcoming_outlined,
              ),
              _filterTile(
                "Past Subscriptions",
                SubscriptionFilter.past,
                Icons.history_rounded,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() => activeFilter = null);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Clear filter',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterTile(String title, SubscriptionFilter filter, IconData icon) {
    final bool selected = activeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() => activeFilter = filter);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? _indigo.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: selected
                ? _indigo.withOpacity(0.4)
                : Colors.white.withOpacity(0.07),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? _indigoLight : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: selected
                      ? _indigoLight
                      : Colors.white.withOpacity(0.7),
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 16, color: _indigoLight),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Expanded(
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: CircularProgressIndicator(color: _indigo, strokeWidth: 2),
        ),
      );
    }

    final list = filteredSubscriptions;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 40,
                color: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(height: 12),
              Text(
                'No subscriptions found',
                style: GoogleFonts.dmSans(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final sub = list[index];
        return _subscriptionTile(sub);
      },
    );
  }

  Widget _subscriptionTile(Subscription sub) {
    final color = _categoryColor(sub.category);
    final icon = _iconForCategory(sub.category);

    // Days until payment label
    String? daysLabel;
    Color daysColor = Colors.white.withOpacity(0.3);
    if (sub.nextPaymentDate != null) {
      final days = sub.nextPaymentDate!
          .difference(
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ),
          )
          .inDays;
      if (days == 0) {
        daysLabel = 'Today';
        daysColor = const Color(0xFFE24B4A);
      } else if (days == 1) {
        daysLabel = 'Tomorrow';
        daysColor = const Color(0xFFF59E0B);
      } else if (days <= 7) {
        daysLabel = 'In $days days';
        daysColor = const Color(0xFFF59E0B);
      } else if (days > 0) {
        daysLabel = 'In $days days';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          // Name + cycle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.serviceName,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      sub.billingCycle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    if (daysLabel != null) ...[
                      Text(
                        '  ·  ',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      Text(
                        daysLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: daysColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${sub.cost.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              // Category pill
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sub.category,
                  style: GoogleFonts.dmSans(fontSize: 10, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    final monthlySpend = calculateMonthlySpend(subscriptions);
    final yearlySpend = yearlyCost(subscriptions);

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentPage: DrawerPage.subscriptions),
      // ── AppBar ──
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

      // ── Body ──
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page heading ──
              Text(
                'Overview',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${subscriptions.length} active subscription${subscriptions.length == 1 ? '' : 's'}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),

              const SizedBox(height: 20),

              // ── Summary cards row 1 ──
              Row(
                children: [
                  _buildSummaryCard(
                    icon: Icons.calendar_month_outlined,
                    iconColor: _indigo,
                    title: 'Monthly spend',
                    value: '₹${monthlySpend.toStringAsFixed(0)}',
                    accentColor: _indigo,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    icon: Icons.grid_view_rounded,
                    iconColor: _cyan,
                    title: 'Active subs',
                    value: subscriptions.length.toString(),
                    accentColor: _cyan,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Summary cards row 2 ──
              Row(
                children: [
                  _buildSummaryCard(
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Yearly spend',
                    value: '₹${yearlySpend.toStringAsFixed(0)}',
                    accentColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    icon: Icons.upcoming_outlined,
                    iconColor: const Color(0xFF818CF8),
                    title: 'Next payment',
                    value: nextPaymentText(),
                    accentColor: const Color(0xFF818CF8),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Subscriptions header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscriptions',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      if (activeFilter != null)
                        Text(
                          'Filtered',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _indigoLight,
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: activeFilter != null
                            ? _indigo.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: activeFilter != null
                              ? _indigo.withOpacity(0.4)
                              : Colors.white.withOpacity(0.08),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: activeFilter != null
                                ? _indigoLight
                                : Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filter',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: activeFilter != null
                                  ? _indigoLight
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── List ──
              _buildSubscriptionsList(),
            ],
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_indigo, _cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _indigo.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: const Color(0xFF0F1424),
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.1,
                  maxChildSize: 0.8,
                  expand: false,
                  builder: (context, scrollController) => AddSubscriptionDialog(
                    onSubscriptionAdded: fetchSubscriptions,
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

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

IconData _iconForCategory(String category) {
  switch (category) {
    case "Streaming":
      return Icons.tv_outlined;
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
      return Icons.fitness_center_outlined;
    default:
      return Icons.subscriptions_outlined;
  }
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
      return sub.cost * 4.33;
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
  return nearestDays ?? -1;
}

double yearlyCost(List<Subscription> subs) =>
    calculateMonthlySpend(subs) * 12.00;

String nextPaymentText() {
  if (nearestPaymentDays == -1) return "None";
  if (nearestPaymentDays == 0) return "Today";
  if (nearestPaymentDays == 1) return "Tomorrow";
  return "${nearestPaymentDays}d";
}
