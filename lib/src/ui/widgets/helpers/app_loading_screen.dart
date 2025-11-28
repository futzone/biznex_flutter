import 'package:biznex/biznex.dart';
import 'package:flutter/material.dart';

Widget RefLoadingScreen() => AppLoadingScreen();

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
          child: CircularProgressIndicator(
            strokeWidth: 8,
            color: AppColors( isDark: false).mainColor,
          ),
        ),
      ),
    );
  }
}
