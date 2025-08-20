 import 'package:flutter/material.dart';

class AppLoadingScreen extends StatelessWidget {
  final EdgeInsets? padding;

  const AppLoadingScreen({this.padding = EdgeInsets.zero, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SizedBox(
            height: 80,
            width: 80,
            child: Image.asset(
              "assets/animations/output-onlinegiftools.gif",
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
