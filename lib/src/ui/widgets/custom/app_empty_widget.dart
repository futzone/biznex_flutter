
import 'package:biznex/src/core/constants/app_locales.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppEmptyWidget extends StatelessWidget {
  final String? text;
  final double? size;

  const AppEmptyWidget({super.key, this.text, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/out-of-stock.png',
            height: size ?? context.s(100),
            width: size ?? context.s(100),
            fit: BoxFit.cover,
          ),
          Text(
            text ?? AppLocales.dataNotFound.tr(),
            style: TextStyle(fontFamily: boldFamily, fontSize: context.s((size ?? 80) * 0.25)),
          ),
        ],
      ),
    );
  }
}
