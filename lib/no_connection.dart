import 'package:flutter/material.dart';

class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/no_internet_icon.png'),
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}
