// import 'package:flutter/material.dart';

// class DrawerItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const DrawerItem({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: isSelected ? Color(0xFF3b82f6) : Colors.grey),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: isSelected ? Color(0xFF3b82f6) : Colors.grey,
//           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//       selected: isSelected,
//       // selectedTileColor: Colors.deepOrangeAccent,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       onTap: () {
//         Navigator.pop(context);
//         onTap();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF3b82f6).withOpacity(0.18) // FULL ROW highlight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                icon,
                color: isSelected ? Color(0xFF3b82f6) : Colors.grey,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Color(0xFF3b82f6) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
