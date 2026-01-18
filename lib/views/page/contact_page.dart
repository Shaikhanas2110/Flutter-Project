import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Color(0xFF1f1f1f)),
        ),
        automaticallyImplyLeading: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wallet_rounded, size: 35, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('SubTracker', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Get In Touch",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Have questions or feedback? We'd love to hear from you",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                summaryCard(
                  context,
                  icon: Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: 'support@subtracker.com',
                  value: Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  color: Color(0xFF16a34a),
                  boxColor: Color(0xFFdcfce7),
                ),
                SizedBox(height: 20),
                summaryCard(
                  context,
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: '+91 9265-88-6444',
                  value: Text(
                    "Phone",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  color: Colors.purpleAccent,
                  boxColor: Color(0xFFdcfce7),
                ),
                SizedBox(height: 20),
                summaryCard(
                  context,
                  icon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: 'Ahmedabad',
                  value: Text(
                    "Office",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  color: Colors.orangeAccent,
                  boxColor: Color(0xFFdcfce7),
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
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
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
    ),
  );
}
