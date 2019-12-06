library explode_view;

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

// The duration for the scattering the particles and fade out
const explosionDuration = Duration(milliseconds: 1500);

// The duration for shaking the image while creating the particles
const shakingDuration = Duration(milliseconds: 3000);

class ExplodeView extends StatelessWidget {

  final String imagePath;

  const ExplodeView({
    @required this.imagePath
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return new MaterialApp(
      home: new ExplodeViewBody(screenSize: size, imagePath: imagePath),
    );
  }
}

class ExplodeViewBody extends StatefulWidget {
  final Size screenSize;
  final String imagePath;

  ExplodeViewBody({Key key, @required this.screenSize, @required this.imagePath}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExplodeViewState();
}

class _ExplodeViewState extends State<ExplodeViewBody> with TickerProviderStateMixin{

  GlobalKey currentKey;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  bool useSnapshot = true;
  Random random;

  AnimationController imageAnimationController;

  double imageSize = 50.0;

  @override
  void initState() {
    super.initState();

    currentKey = useSnapshot ? paintKey : imageKey;
    random = new Random();

    imageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          
        ],
      ),
    );
  }

  @override
  void dispose(){
    imageAnimationController.dispose();
    super.dispose();
  }

}