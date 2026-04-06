import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: screenWidth > 500 ? 420 : double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: screenWidth > 500
                ? const [
              BoxShadow(
                blurRadius: 15,
                color: Colors.black12,
                offset: Offset(0, 5),
              )
            ]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }
}