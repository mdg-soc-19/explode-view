import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:explode_view/explode_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explode View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Explode View'),
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
            ExplodeView(
                imagePath: 'assets/images/swiggy.png',
                imagePosFromLeft: 50.0,
                imagePosFromTop: 200.0),
            ExplodeView(
                imagePath: 'assets/images/chrome.png',
                imagePosFromLeft: 200.0,
                imagePosFromTop: 400.0),
            ExplodeView(
                imagePath: 'assets/images/firefox.png',
                imagePosFromLeft: 350.0,
                imagePosFromTop: 600.0)
          ],
        )));
  }
}
