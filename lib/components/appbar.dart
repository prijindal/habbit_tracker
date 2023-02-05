import 'package:flutter/material.dart';
import '../pages/profile.dart';

class MyAppBar extends AppBar {
  MyAppBar(
      {super.key, required this.context, this.title = const Text("Relapse")});

  final BuildContext context;

  @override
  final Widget? title;
  // Widget get title => const Text("Relapse");

  @override
  List<Widget>? get actions => [
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: const Icon(
                Icons.person,
                size: 26.0,
              ),
            )),
      ];
}
