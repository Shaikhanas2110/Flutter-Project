import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/container_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ContainerWidget(title: 'Anas', desc: 'This is the description!!'),
                ContainerWidget(title: 'Anas', desc: 'This is the description!!'),
                ContainerWidget(title: 'Anas', desc: 'This is the description!!'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
