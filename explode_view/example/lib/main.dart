import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:explode_view/explode_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Liquid Pull To Refresh'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: AppBar(
          title: Text("Explode View"),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Container(
          child: Stack(
            children: <Widget>[
              ExplodeView(imagePath: 'assets/images/swiggy.png', imagePosFromLeft: 200.0, imagePosFromTop: 600.0),
              ExplodeView(imagePath: 'assets/images/chrome.png', imagePosFromLeft: 100.0, imagePosFromTop: 200.0),
              ExplodeView(imagePath: 'assets/images/firefox.png', imagePosFromLeft: 300.0, imagePosFromTop: 400.0)
            ],
          )
      )

    );

  }

}

