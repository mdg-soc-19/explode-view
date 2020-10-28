import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';

import 'package:explode_view/explode_view.dart';

Directory applicationDocumentsDirectory;
File pathProviderDemoResultFile;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

  // loading sample image asset in to memory
  final ByteData sampleImage =
      await rootBundle.load('assets/images/swiggy.png');

  // stores sample image in application documents directory
  pathProviderDemoResultFile =
      await File('${applicationDocumentsDirectory.path}/path_provider_demo.png')
          .writeAsBytes(sampleImage.buffer.asUint8List());

  runApp(MyApp());
}

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
            FutureBuilder<Uint8List>(
              future: pathProviderDemoResultFile.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return ExplodeView(
                      imageBytes: ByteData.view(snapshot.data.buffer),
                      imagePosFromLeft: 50.0,
                      imagePosFromTop: 200.0);
                }
                return Container();
              },
            ),
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
