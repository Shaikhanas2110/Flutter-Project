import 'package:flutter/material.dart';
import 'package:my_app/views/data/notifiers.dart';
import 'package:my_app/views/pages/home_page.dart';
import 'package:my_app/views/pages/profile_page.dart';
import 'package:my_app/views/widgets/navbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Widget> pages = [HomePage(), ProfileWidget()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter App"),
        actions: [
          IconButton(
            onPressed: () async {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool('theme', isDarkModeNotifier.value);
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
              },
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return SettingsPage();
          //         },
          //       ),
          //     );
          //   },
          //   icon: Icon(Icons.settings),
          // ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: SelectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),

      bottomNavigationBar: NavBarWidget(),
    );
  }
}
