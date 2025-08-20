import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';



class MySecondWindowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Ikkinchi oyna')),
        body: Center(child: Text('Bu yangi oyna!')),
      ),
    );
  }
}
