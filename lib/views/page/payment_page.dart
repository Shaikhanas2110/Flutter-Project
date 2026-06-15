import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/payment_buckets.dart';
import 'package:my_app/views/data/classes/subscriptions.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

List<Subscription> subscriptions = [];
bool isLoading = true;

class _PaymentScreenState extends State<PaymentScreen> {
  // ── Brand colors ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _card = Color(0xFF131929);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _indigoLight = Color(0xFF818CF8);
  static const Color _border = Color(0x1AFFFFFF);
  static const Color _errorRed = Color(0xFFE24B4A);
  static const Color _amber = Color(0xFFF59E0B);

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

  // ── Urgency color for payment date ──
  Color _dateColor(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final days = date.difference(today).inDays;
    if (days == 0) return _errorRed;
    if (days <= 3) return _errorRed;
    if (days <= 7) return _amber;
    return Colors.white.withOpacity(0.3);
  }

  String _dateLabel(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final days = date.difference(today).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 7) return 'In $days days';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ── Section header ──
  Widget _sectionHeader(String title, {String? count}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _indigo.withOpacity(0.12),
                border: Border.all(color: _indigo.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: _indigoLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ──
  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 24,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment tile ──
  Widget _paymentTile(Subscription sub) {
    final color = _categoryColor(sub.category);
    final icon = _iconForCategory(sub.category);
    final date = sub.nextPaymentDate;

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

          // Name + category
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
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
          ),

          // Price + date
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
              const SizedBox(height: 4),
              if (date != null)
                Text(
                  _dateLabel(date),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _dateColor(date),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buckets = splitSubscriptionsByDate(subscriptions);
    final totalThisMonth = totalDueThisMonth(subscriptions);

    // Count upcoming (this week + this month + next month)
    final totalUpcoming =
        buckets.thisWeek.length +
        buckets.thisMonth.length +
        buckets.nextMonth.length;

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentPage: DrawerPage.payments),
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
              'SubTracker',
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
                      'Payments',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalUpcoming upcoming payment${totalUpcoming == 1 ? '' : 's'}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Due this month banner ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _indigo.withOpacity(0.2),
                            _cyan.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: _indigo.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _indigo.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              color: _indigoLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due this month',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${totalThisMonth.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── This Week ──
                    _sectionHeader(
                      'This Week',
                      count: buckets.thisWeek.isEmpty
                          ? null
                          : '${buckets.thisWeek.length}',
                    ),
                    if (buckets.thisWeek.isEmpty)
                      _emptyState('No payments due this week')
                    else
                      ...buckets.thisWeek.map(_paymentTile),

                    const SizedBox(height: 28),

                    // ── This Month ──
                    _sectionHeader(
                      'This Month',
                      count: buckets.thisMonth.isEmpty
                          ? null
                          : '${buckets.thisMonth.length}',
                    ),
                    if (buckets.thisMonth.isEmpty)
                      _emptyState('No more payments this month')
                    else
                      ...buckets.thisMonth.map(_paymentTile),

                    const SizedBox(height: 28),

                    // ── Next Month ──
                    _sectionHeader(
                      'Next Month',
                      count: buckets.nextMonth.isEmpty
                          ? null
                          : '${buckets.nextMonth.length}',
                    ),
                    if (buckets.nextMonth.isEmpty)
                      _emptyState('No payments scheduled next month')
                    else
                      ...buckets.nextMonth.map(_paymentTile),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

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
