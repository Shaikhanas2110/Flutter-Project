import 'package:flutter/material.dart';

class BezierClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var heightOffset = height * 0.2;
    Path path = Path();
    path.lineTo(0, height - heightOffset);
    path.quadraticBezierTo(width * 0.5, height, width, height - heightOffset);
    path.lineTo(width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: BezierClipper1(),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: double.infinity,
                    color: Colors.teal,
                  ),
                ),
                Text("HELLO WORLS!!"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
