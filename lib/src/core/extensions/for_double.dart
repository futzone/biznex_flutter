import 'package:flutter/cupertino.dart';

extension DoubleHelpers on num {
  String get price {
    if (isNaN || !isFinite) return '0';
    return toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }

  String get priceUZS => "$price UZS";

  Widget get w {
    return SizedBox(width: toDouble());
  }

  Widget get h {
    return SizedBox(height: toDouble());
  }

  EdgeInsets get lr {
    return EdgeInsets.only(left: toDouble(), right: toDouble());
  }

  EdgeInsets get tb {
    return EdgeInsets.only(top: toDouble(), bottom: toDouble());
  }

  EdgeInsets get all {
    return EdgeInsets.all(toDouble());
  }

  EdgeInsets get left {
    return EdgeInsets.only(left: toDouble());
  }

  EdgeInsets get right {
    return EdgeInsets.only(right: toDouble());
  }

  EdgeInsets get bottom {
    return EdgeInsets.only(bottom: toDouble());
  }

  EdgeInsets get top {
    return EdgeInsets.only(top: toDouble());
  }

  String get toMeasure {
    if (this % 1 == 0) {
      return toInt().toString();
    }

    if ("$this".split(".").last.startsWith("00")) {
      return toInt().toString();
    }
    final str = toStringAsFixed(3);
    final trimmed = double.parse(str).toString();
    return trimmed;
  }
}


