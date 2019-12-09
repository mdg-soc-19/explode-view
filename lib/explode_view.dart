library explode_view;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

// The duration for the scattering the particles and fade out
const explosionDuration = Duration(milliseconds: 1500);

// The duration for shaking the image while creating the particles
const shakingDuration = Duration(milliseconds: 3000);

// Total number of particles to be generated
const noOfParticles = 64;

class ExplodeView extends StatelessWidget {
  /// The path where the image is located
  final String imagePath;

  /// The coordinates of the image from the left edge of the screen
  final double imagePosFromLeft;

  /// The coordinates of the image from the top edge of the screen
  final double imagePosFromTop;

  /// The constructor for the ExplodeView class
  const ExplodeView(
      {@required this.imagePath,
      @required this.imagePosFromLeft,
      @required this.imagePosFromTop});

  @override
  Widget build(BuildContext context) {
    // This variable contains the size of the screen
    final screenSize = MediaQuery.of(context).size;

    return new Container(
      child: new ExplodeViewBody(
          screenSize: screenSize,
          imagePath: imagePath,
          imagePosFromLeft: imagePosFromLeft,
          imagePosFromTop: imagePosFromTop),
    );
  }
}

class ExplodeViewBody extends StatefulWidget {
  final Size screenSize;
  final String imagePath;
  final double imagePosFromLeft;
  final double imagePosFromTop;

  ExplodeViewBody(
      {Key key,
      @required this.screenSize,
      @required this.imagePath,
      @required this.imagePosFromLeft,
      @required this.imagePosFromTop})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExplodeViewState();
}

class _ExplodeViewState extends State<ExplodeViewBody>
    with TickerProviderStateMixin {
  /// Keys that are unique across the entire app.
  GlobalKey currentKey;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  bool useSnapshot = true;
  bool isImage = true;
  math.Random random;

  /// [ListView] that contains the list of different particles
  final List<Particle> particles = [];

  /// AnimationController used for the shaking of the image
  AnimationController imageAnimationController;

  /// imageSize is used as height and width of the image
  ///
  /// default to value 50.0
  double imageSize = 50.0;

  /// Controller that allows sending events on stream on change of the colors of the pixels
  final StreamController<Color> _stateController =
      StreamController<Color>.broadcast();
  img.Image photo;

  @override
  void initState() {
    super.initState();

    currentKey = useSnapshot ? paintKey : imageKey;
    random = new math.Random();

    imageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000),
    );
  }

  // Returns the Vector3 object required for shaking the image
  Vector3 _shakeImage() {
    return Vector3(
        math.sin((imageAnimationController.value) * math.pi * 20.0) * 8,
        0.0,
        0.0);
  }

  // Loads the bytes of the image and sets it in the img.Image object
  Future<void> loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(widget.imagePath);
    setImageBytes(imageBytes);
  }

  // Loads the bytes of the snapshot if the img.Image object is null
  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes =
        await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes);
    capture.dispose();
  }

  // Setting image bytes to the img.Image object
  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    photo = img.decodeImage(values);
  }

  Future<Color> getPixel(
      Offset globalPosition, Offset position, double size) async {
    if (photo == null) {
      await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
    }

    Color newColor = calculatePixel(globalPosition, position, size);
    return newColor;
  }

  // This method returns the color at the particular pixel of the image
  Color calculatePixel(Offset globalPosition, Offset position, double size) {
    double px = position.dx;
    double py = position.dy;

    if (!useSnapshot) {
      double widgetScale = size / photo.width;
      px = (px / widgetScale);
      py = (py / widgetScale);
    }

    int pixel32 = photo.getPixelSafe(px.toInt() + 1,
        py.toInt()); // getting the pixel value at particular position

    int hex = abgrToArgb(pixel32);

    // Adds color to the StreamController which will be send to the stream as another event
    _stateController.add(Color(hex));

    Color returnColor = Color(hex);

    return returnColor;
  }

  // As image.dart library uses KML format i.e. #AABBGGRR, this method converts it to normal #AARRGGBB format
  int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: isImage
            ? StreamBuilder(
                initialData: Colors.green[500],
                stream: _stateController.stream,
                builder: (buildContext, snapshot) {
                  return Stack(
                    children: <Widget>[
                      RepaintBoundary(
                        key: paintKey,
                        child: GestureDetector(
                          onLongPress: () async {
                            imageAnimationController.forward();

                            // A render object of the image
                            RenderBox box =
                                imageKey.currentContext.findRenderObject();

                            // Getting the imagePosition from the RenderBox object
                            Offset imagePosition =
                                box.localToGlobal(Offset.zero);
                            double imagePositionOffsetX = imagePosition.dx;
                            double imagePositionOffsetY = imagePosition.dy;

                            double imageCenterPositionX =
                                imagePositionOffsetX + (imageSize / 2);
                            double imageCenterPositionY =
                                imagePositionOffsetY + (imageSize / 2);

                            final List<Color> colors = [];

                            // Getting colors from the pixels and adding it to the List i.e. colors
                            for (int i = 0; i < noOfParticles; i++) {
                              if (i < 21) {
                                getPixel(
                                        imagePosition,
                                        Offset(imagePositionOffsetX + (i * 0.7),
                                            imagePositionOffsetY - 60),
                                        box.size.width)
                                    .then((value) {
                                  colors.add(value);
                                });
                              } else if (i >= 21 && i < 42) {
                                getPixel(
                                        imagePosition,
                                        Offset(imagePositionOffsetX + (i * 0.7),
                                            imagePositionOffsetY - 52),
                                        box.size.width)
                                    .then((value) {
                                  colors.add(value);
                                });
                              } else {
                                getPixel(
                                        imagePosition,
                                        Offset(imagePositionOffsetX + (i * 0.7),
                                            imagePositionOffsetY - 68),
                                        box.size.width)
                                    .then((value) {
                                  colors.add(value);
                                });
                              }
                            }

                            Future.delayed(Duration(milliseconds: 4000), () {
                              // Adding the particles to the List of Particle class i.e. particles
                              for (int i = 0; i < noOfParticles; i++) {
                                if (i < 21) {
                                  particles.add(Particle(
                                      id: i,
                                      screenSize: widget.screenSize,
                                      colors: colors[i].withOpacity(1.0),
                                      offsetX: (imageCenterPositionX -
                                              imagePositionOffsetX +
                                              (i * 0.7)) *
                                          0.1,
                                      offsetY: (imageCenterPositionY -
                                              (imagePositionOffsetY - 60)) *
                                          0.1,
                                      newOffsetX:
                                          imagePositionOffsetX + (i * 0.7),
                                      newOffsetY: imagePositionOffsetY - 60));
                                } else if (i >= 21 && i < 42) {
                                  particles.add(Particle(
                                      id: i,
                                      screenSize: widget.screenSize,
                                      colors: colors[i].withOpacity(1.0),
                                      offsetX: (imageCenterPositionX -
                                              imagePositionOffsetX +
                                              (i * 0.5)) *
                                          0.1,
                                      offsetY: (imageCenterPositionY -
                                              (imagePositionOffsetY - 52)) *
                                          0.1,
                                      newOffsetX:
                                          imagePositionOffsetX + (i * 0.7),
                                      newOffsetY: imagePositionOffsetY - 52));
                                } else {
                                  particles.add(Particle(
                                      id: i,
                                      screenSize: widget.screenSize,
                                      colors: colors[i].withOpacity(1.0),
                                      offsetX: (imageCenterPositionX -
                                              imagePositionOffsetX +
                                              (i * 0.9)) *
                                          0.1,
                                      offsetY: (imageCenterPositionY -
                                              (imagePositionOffsetY - 68)) *
                                          0.1,
                                      newOffsetX:
                                          imagePositionOffsetX + (i * 0.7),
                                      newOffsetY: imagePositionOffsetY - 68));
                                }
                              }

                              setState(() {
                                // Setting isImage false to disappear the image
                                isImage = false;
                              });
                            });
                          },
                          child: Container(
                            alignment: FractionalOffset(
                                (widget.imagePosFromLeft /
                                    widget.screenSize.width),
                                (widget.imagePosFromTop /
                                    widget.screenSize.height)),
                            child: Transform(
                              transform: Matrix4.translation(_shakeImage()),
                              child: Image.asset(
                                widget.imagePath,
                                key: imageKey,
                                width: imageSize,
                                height: imageSize,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            : Container(
                child: Stack(
                  children: <Widget>[
                    for (Particle particle in particles)
                      particle.startParticleAnimation()
                  ],
                ),
              ));
  }

  @override
  void dispose() {
    imageAnimationController.dispose();
    super.dispose();
  }
}

class Particle extends _ExplodeViewState {
  int id;
  Size screenSize;
  Offset position;
  Paint singleParticle;

  double offsetX = 0.0, offsetY = 0.0;
  double newOffsetX = 0.0, newOffsetY = 0.0;

  static final randomValue = math.Random();
  AnimationController animationController;

  // Tween objects for setting Offset of the particle while translation
  Animation translateXAnimation, negatetranslateXAnimation;
  Animation translateYAnimation, negatetranslateYAnimation;

  // Tween objects for setting opacity of the particle while translation
  Animation fadingAnimation;

  // Tween objects for setting size of the particle while translation
  Animation particleSize;

  double lastXOffset, lastYOffset;
  Color colors;

  Particle(
      {@required this.id,
      @required this.screenSize,
      this.colors,
      this.offsetX,
      this.offsetY,
      this.newOffsetX,
      this.newOffsetY}) {
    position = Offset(this.offsetX, this.offsetY);

    math.Random random = new math.Random();
    this.lastXOffset = random.nextDouble() * 100;
    this.lastYOffset = random.nextDouble() * 100;

    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    // Defining the Tween objects
    translateXAnimation = Tween(begin: position.dx, end: lastXOffset)
        .animate(animationController);
    translateYAnimation = Tween(begin: position.dy, end: lastYOffset)
        .animate(animationController);
    negatetranslateXAnimation =
        Tween(begin: -1 * position.dx, end: -1 * lastXOffset)
            .animate(animationController);
    negatetranslateYAnimation =
        Tween(begin: -1 * position.dy, end: -1 * lastYOffset)
            .animate(animationController);
    fadingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(animationController);

    particleSize = Tween(begin: 5.0, end: random.nextDouble() * 20)
        .animate(animationController);
  }

  // This method starts the animation of the particle
  startParticleAnimation() {
    animationController.forward();

    return Container(
      alignment: FractionalOffset(
          (newOffsetX / screenSize.width), (newOffsetY / screenSize.height)),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget widget) {
          if (id % 4 == 0) {
            return Transform.translate(
                offset: Offset(
                    translateXAnimation.value, translateYAnimation.value),
                child: FadeTransition(
                  opacity: fadingAnimation,
                  child: Container(
                    width: particleSize.value > 5 ? particleSize.value : 5,
                    height: particleSize.value > 5 ? particleSize.value : 5,
                    decoration:
                        BoxDecoration(color: colors, shape: BoxShape.circle),
                  ),
                ));
          } else if (id % 4 == 1) {
            return Transform.translate(
                offset: Offset(
                    negatetranslateXAnimation.value, translateYAnimation.value),
                child: FadeTransition(
                  opacity: fadingAnimation,
                  child: Container(
                    width: particleSize.value > 5 ? particleSize.value : 5,
                    height: particleSize.value > 5 ? particleSize.value : 5,
                    decoration:
                        BoxDecoration(color: colors, shape: BoxShape.circle),
                  ),
                ));
          } else if (id % 4 == 2) {
            return Transform.translate(
                offset: Offset(
                    translateXAnimation.value, negatetranslateYAnimation.value),
                child: FadeTransition(
                  opacity: fadingAnimation,
                  child: Container(
                    width: particleSize.value > 5 ? particleSize.value : 5,
                    height: particleSize.value > 5 ? particleSize.value : 5,
                    decoration:
                        BoxDecoration(color: colors, shape: BoxShape.circle),
                  ),
                ));
          } else {
            return Transform.translate(
                offset: Offset(negatetranslateXAnimation.value,
                    negatetranslateYAnimation.value),
                child: FadeTransition(
                  opacity: fadingAnimation,
                  child: Container(
                    width: particleSize.value > 5 ? particleSize.value : 5,
                    height: particleSize.value > 5 ? particleSize.value : 5,
                    decoration:
                        BoxDecoration(color: colors, shape: BoxShape.circle),
                  ),
                ));
          }
        },
      ),
    );
  }
}
