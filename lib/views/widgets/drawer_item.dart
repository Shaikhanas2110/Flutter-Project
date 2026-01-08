import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
      onTap: () {
        Navigator.pop(context); // close drawer
        onTap();
      },
    );
  }
}
