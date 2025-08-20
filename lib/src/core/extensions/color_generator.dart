import 'dart:math';
import 'package:flutter/material.dart';

Color generateColorFromString(String input) {
  final hash = input.codeUnits.fold(0, (prev, elem) => prev + elem);
  final rng = Random(hash);

  int r = rng.nextInt(200);
  int g = rng.nextInt(200);
  int b = rng.nextInt(200);

  double luminance = (0.299 * r + 0.587 * g + 0.114 * b);
  if (luminance > 150) {
    r = max(0, r - 50);
    g = max(0, g - 50);
    b = max(0, b - 50);
  }

  return Color.fromARGB(255, r, g, b);
}

Color colorFromStatus(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'opened':
      return Colors.orange;
    case 'confirmed':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
