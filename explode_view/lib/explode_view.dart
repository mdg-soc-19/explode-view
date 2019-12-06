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

class Particle extends _ExplodeViewState {

  int id;
  Size screenSize;
  Offset position;
  Paint singleParticle;

  double offsetX=0.0, offsetY=0.0;
  double newOffsetX = 0.0, newOffsetY = 0.0;

  static final randomValue = Random();
  AnimationController animationController;

  Animation translateXAnimation, negatetranslateXAnimation;
  Animation translateYAnimation, negatetranslateYAnimation;
  Animation fadingAnimation;
  Animation particleSize;

  double lastXOffset, lastYOffset;
  Color colors;


  Particle({@required this.id, @required this.screenSize, this.colors, this.offsetX, this.offsetY, this.newOffsetX, this.newOffsetY}) {

    position = Offset(this.offsetX, this.offsetY);

    Random random = new Random();
    this.lastXOffset = random.nextDouble() * 100;
    this.lastYOffset = random.nextDouble() * 100;

    animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500)
    );

    translateXAnimation = Tween(begin: position.dx, end: lastXOffset).animate(animationController);
    translateYAnimation = Tween(begin: position.dy, end: lastYOffset).animate(animationController);
    negatetranslateXAnimation = Tween(begin: -1 * position.dx, end: -1 * lastXOffset).animate(animationController);
    negatetranslateYAnimation = Tween(begin: -1 * position.dy, end: -1 * lastYOffset).animate(animationController);
    fadingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(animationController);

    particleSize = Tween(begin: 5.0, end: random.nextDouble() * 20).animate(animationController);

  }

  startParticleAnimation() {
    animationController.forward();

    return Container(
      alignment: FractionalOffset((newOffsetX / screenSize.width), (newOffsetY / screenSize.height)),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget widget) {
          if(id % 4 == 0){
            return Transform.translate(
              offset: Offset(translateXAnimation.value, translateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else if(id % 4 == 1){
            return Transform.translate(
              offset: Offset(negatetranslateXAnimation.value, translateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else if(id % 4 == 2){
            return Transform.translate(
              offset: Offset(translateXAnimation.value, negatetranslateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }else{
            return Transform.translate(
              offset: Offset(negatetranslateXAnimation.value, negatetranslateYAnimation.value),
              child: FadeTransition(
                opacity: fadingAnimation,
                child: Container(
                  width: particleSize.value>5 ? particleSize.value : 5,
                  height: particleSize.value>5 ? particleSize.value : 5,
                  decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle
                  ),
                ),
              )
            );
          }
        },
      ),
    );
  }
}