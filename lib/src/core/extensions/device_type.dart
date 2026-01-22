import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;

  if (width >= 1200) {
    return DeviceType.desktop;
  } else if (width >= 600) {
    return DeviceType.tablet;
  } else {
    return DeviceType.mobile;
  }
}

extension DeviceTypeCheck on BuildContext {
  bool get notDesktop {
    final dType = getDeviceType(this);
    return dType == DeviceType.mobile || dType == DeviceType.tablet;
  }

  double getSize(double mobile, {double? d, double? t}) {
    final dType = getDeviceType(this);
    if (dType == DeviceType.mobile) return mobile;
    if (dType == DeviceType.tablet) return t ?? mobile;
    if (dType == DeviceType.desktop) return d ?? mobile;

    return mobile;
  }
}
