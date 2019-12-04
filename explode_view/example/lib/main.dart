import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _DemoPageState createState() => new _DemoPageState();

  DemoPage() {
    timeDilation = 1.0;
  }
}

class _DemoPageState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Flutter",
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return new MaterialApp(
      home: new DemoBody(screenSize: size),
    );
  }
}

class DemoBody extends StatefulWidget {
  final Size screenSize;

  DemoBody({Key key, @required this.screenSize}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<DemoBody> with TickerProviderStateMixin{

  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  final List<Particle> particles = [];
  Random random;

  double leftPos=10.0, topPos=10.0;

  bool useSnapshot = true;
  bool isImage = true;
  String imagePath = 'assets/images/chrome.png';
  double imageSize = 50.0;

  GlobalKey currentKey;

  AnimationController imageAnimationController;
  Animation<double> imageAnimation;

  final StreamController<Color> _stateController = StreamController<Color>.broadcast();
  img.Image photo;

  @override
  void initState() {
    super.initState();

    currentKey = useSnapshot ? paintKey : imageKey;
    random = new Random();

    imageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    imageAnimation = Tween<double>(
      begin: 50.0,
      end: 500.0,
    ).animate(imageAnimationController);

  }

  Vector3 _shake() {
    double progress = imageAnimationController.value;
    double offset = sin(progress * pi * 5.0);
    return Vector3(offset * 2.0, 0.0, 0.0);
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: AppBar(
              title: Text("Explode View"),
              automaticallyImplyLeading: false,
            ),
          ),
          body: Container(
              child: isImage
                  ? StreamBuilder(
                  initialData: Colors.green[500],
                  stream: _stateController.stream,
                  builder: (buildContext, snapshot) {
                    Color selectedColor = snapshot.data ?? Colors.green;
                    return Stack(
                      children: <Widget>[
                        RepaintBoundary(
                          key: paintKey,
                          child: GestureDetector(
                            onLongPress: () {

                              RenderBox box = imageKey.currentContext.findRenderObject();
                              Offset position = box.localToGlobal(Offset.zero);
                              double offsetX = position.dx;
                              double offsetY = position.dy;


                              double offsetXCenter = offsetX + (imageSize/2);
                              double offsetYCenter = offsetY + (imageSize/2);


                              imageAnimationController.forward();

                              final List<Color> colors = [];

//                              print("OffsetX     : "+(offsetX).toString()+"\n OffsetY    : "+(offsetY-50).toString());
                              for(int i=0;i<128;i++){
                                setState(() {
                                  leftPos = offsetX.toDouble();
                                  topPos = (offsetY-60).toDouble();
                                });
                                if(i<42){
                                  getPixel(position, Offset(offsetX+i*0.7, offsetY-(60)), box.size.width).then((value) {
                                    colors.add(value);
                                  });
                                }else if(i>=42 && i<84){
                                  getPixel(position, Offset(offsetX+i*0.7, offsetY-(52)), box.size.width).then((value) {
                                    colors.add(value);
                                  });
                                }else{
                                  getPixel(position, Offset(offsetX+i*0.7, offsetY-(68)), box.size.width).then((value) {
                                    colors.add(value);
                                  });
                                }
                              }


                              Future.delayed(Duration(milliseconds: 6000), () {

                                for(int i=0;i<128;i++){
                                  if(i<42){
                                    particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (offsetXCenter-offsetX+i*0.7)*0.1, offsetY: (offsetYCenter-(offsetY-60))*0.1, newOffsetX: offsetX+i*0.7, newOffsetY: offsetY-60));
                                  }else if(i>=43 && i<84){
                                    particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (offsetXCenter-offsetX+i*0.7)*0.1, offsetY: (offsetYCenter-(offsetY-52))*0.1, newOffsetX: offsetX+i*0.7, newOffsetY: offsetY-52));
                                  }else{
                                    particles.add(Particle(id: i, screenSize: widget.screenSize, colors: colors[i].withOpacity(1.0), offsetX: (offsetXCenter-offsetX+i*0.7)*0.1, offsetY: (offsetYCenter-(offsetY-68))*0.1, newOffsetX: offsetX+i*0.7, newOffsetY: offsetY-68));
                                  }
                                }

                                setState(() {
                                  isImage = false;
                                });

                              });

                            },
                            child: Container(
                              alignment: FractionalOffset(0.5, 0.5),
                              child: Transform(
                                transform: Matrix4.translation(_shake()),
                                child: Image.asset(
                                  imagePath,
                                  key: imageKey,
                                  width: imageSize,
                                  height: imageSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }):
              Container(
                child: Stack(
                  children: <Widget>[
                    for(Particle particle in particles) particle.buildWidget(),
                    RaisedButton(
                      child: Text("Go Back"),
                      onPressed: () {
                        setState(() {
                          isImage = true;
                        });
                      },
                    ),
                  ],
                ),
              )
          )
      ),
    );
  }


  Future<void> loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(imagePath);
    setImageBytes(imageBytes);
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();
    ByteData imageBytes =
    await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    List<int> values = imageBytes.buffer.asUint8List();
    photo = null;
    photo = img.decodeImage(values);
  }

  Future<Color> getPixel(Offset globalPosition, Offset position, double size) async {
    if (photo == null) {
      await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
    }

    Color newColor = calculatePixel(globalPosition, position, size);
    return newColor;
  }

  Color calculatePixel(Offset globalPosition, Offset position, double size) {

    double px = position.dx;
    double py = position.dy;

//    print("OffsetX: "+(globalPosition.dx+1).toString()+"\n OffsetY: "+(globalPosition.dy+1).toString());


    if (!useSnapshot) {
      double widgetScale = size / photo.width;
      print(py);
      px = (px / widgetScale);
      py = (py / widgetScale);

//      print("Widget Scale:  " + widgetScale.toString());
    }

//    print(photo.getPixelSafe(81, 352));

    int pixel32 = photo.getPixelSafe(px.toInt()+1, py.toInt());
//    print("Pixel32: " + pixel32.toString());

    int hex = abgrToArgb(pixel32);

//    print("ljkdfhkidhfkjhfkjfhgkjhgkjghdkjhgkjg         "+hex.toString());

    _stateController.add(Color(hex));

    Color returnColor = Color(hex);

//    print("Hex color: " + Color(hex).toString());

    return returnColor;
  }


}

int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}

class Particle extends _MyHomePageState{
  int id;
  Size screenSize;
  Offset position;
  Paint singleParticle;
  double offsetX=0.0, offsetY=0.0;
  static final randomValue = Random();
  AnimationController animationController, curveAnimationController;
  Animation translateXAnimation, negatetranslateXAnimation;
  Animation translateYAnimation, negatetranslateYAnimation;
  Animation translateXdashAnimation, negatetranslateXdashAnimation;
  Animation translateYdashAnimation, negatetranslateYdashAnimation;
  Animation fadingAnimation;
  double x,y;
  Color colors;
  double newOffsetX = 0.0, newOffsetY = 0.0;


  Particle({@required this.id, @required this.screenSize, this.colors, this.offsetX, this.offsetY, this.newOffsetX, this.newOffsetY}) {

    position = Offset(this.offsetX, this.offsetY);
//    print("Position value: " + position.toString());

    Random random = new Random();
    this.x = random.nextDouble() * 100;
    this.y = random.nextDouble() * 100;

    animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500)
    );
  }

  Offset getPosition(){
    return this.position;
  }

  buildWidget() {
//    translateXAnimation = Tween(begin: position.dx, end: x).animate(animationController);
    translateYAnimation = Tween(begin: position.dy, end: y).animate(animationController);
//    negatetranslateXAnimation = Tween(begin: -1 * position.dx, end: -1 * x).animate(animationController);
//    negatetranslateYAnimation = Tween(begin: -1 * position.dy, end: -1 * y).animate(animationController);
    fadingAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(animationController);

    Animation scalingAnimation = Tween<double>(
        begin: 1.0,
        end: 1.5
    ).animate(animationController);

    Animation leftRight = Tween<double>(
        begin: position.dx,
        end: 170
    ).animate(animationController);

    Animation up = Tween<double>(
        begin: 20,
        end: 280
    ).animate(animationController);

    Animation down = Tween<double>(
        begin: 20,
        end: 255
    ).animate(animationController);


    double scalingFactor  = 0.4;

    Future.delayed(Duration(milliseconds: 10), () {
      animationController.forward();
    });

    return new Container(
      alignment: FractionalOffset((newOffsetX/screenSize.width), (newOffsetY/screenSize.height)),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget widget){
          if(id % 6 == 0){
            return Transform.translate(
                offset: Offset(getOffset((leftRight.value).round()).dx, getOffset((leftRight.value).round()).dy + translateYAnimation.value),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }else if(id % 6 == 1){
            return Transform.translate(
                offset: Offset(- getOffset((leftRight.value).round()).dx, getOffset((leftRight.value).round()).dy + translateYAnimation.value),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }else if(id % 6 == 2){
            return Transform.translate(
                offset: Offset( -getFifthOffset((down.value).round()).dx - translateYAnimation.value , getFifthOffset((down.value).round()).dy ),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }else if(id % 6 == 3){
            return Transform.translate(
                offset: Offset(-getThirdOffset((up.value).round()).dx - translateYAnimation.value , getThirdOffset((up.value).round()).dy ),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }else if(id % 6 == 4){
            return Transform.translate(
                offset: Offset( getFifthOffset((down.value).round()).dx + translateYAnimation.value , getFifthOffset((down.value).round()).dy ),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }else{
            return Transform.translate(
                offset: Offset( getThirdOffset((up.value).round()).dx + translateYAnimation.value , getThirdOffset((up.value).round()).dy ),
                child: FadeTransition(
                    opacity: fadingAnimation,
                    child: Transform.scale(
                      scale: scalingAnimation.value,
                      child: Container(
//                      width: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
//                      height: translateXAnimation.value > 0 ? translateXAnimation.value*scalingFactor:4,
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                            color: colors,
                            shape: BoxShape.circle
                        ),
                      ),
                    )
                )
            );
          }
        },
      ),
    );

  }

  // returns offsets of path for left/right curve
  Offset getOffset(int x){
    double height = 400;
    double width = 200;

    Path path = Path();
    path.moveTo(offsetX, offsetY);
    path.quadraticBezierTo(width / 2 + offsetX - 30 , - height / 20 + offsetY - 5,  width + offsetX - 130, height / 2 + offsetY - 180);

    final metrics = path.computeMetrics().first;
    final width1 = metrics.getTangentForOffset(metrics.length).position.dx;
    final offset = metrics.getTangentForOffset((x / width1).clamp(0.0, 1.0) * metrics.length).position;

    return offset;
  }

  // returns offsets of path for top curve
  Offset getThirdOffset(int y){

    double height = 400;
    double width = 200;

    Path path = Path();
    path.moveTo(offsetX, offsetY);
//    path.quadraticBezierTo(width / 2 + offsetX - 80 , - height / 20 + offsetY + 100,  width + offsetX - 220, height / 2 + offsetY - 120);
//    path.quadraticBezierTo(width / 2 + offsetX - 30 , - height / 20 + offsetY + 100,  width + offsetX - 140, height / 2 + offsetY - 80);
//    path.quadraticBezierTo(width / 2 + offsetX - 50 , - height / 20 + offsetY - 120,  width + offsetX - 100, - height / 2 + offsetY + 100);
    path.quadraticBezierTo(width / 2 + offsetX - 80 , - height / 20 + offsetY - 50,  width + offsetX - 120, - height / 2 + offsetY + 200);

    final metrics = path.computeMetrics().first;
    final width1 = metrics.getTangentForOffset(metrics.length).position.dx;
    final offset = metrics.getTangentForOffset((y / width1).clamp(0.0, 1.0) * metrics.length).position;

    return offset;
  }

  // returns offsets of path for bottom curve
  Offset getFifthOffset(int y){

    double height = 400;
    double width = 200;

    Path path = Path();
    path.moveTo(offsetX, offsetY);
//    path.quadraticBezierTo(width / 2 + offsetX - 80 , - height / 20 + offsetY + 100,  width + offsetX - 220, height / 2 + offsetY - 120);
//    path.quadraticBezierTo(width / 2 + offsetX - 30 , - height / 20 + offsetY + 100,  width + offsetX - 140, height / 2 + offsetY - 80);
    path.quadraticBezierTo(width / 2 + offsetX - 30 , - height / 20 + offsetY + 40,  width + offsetX - 150, height / 2 + offsetY - 100);

    final metrics = path.computeMetrics().first;
    final width1 = metrics.getTangentForOffset(metrics.length).position.dx;
    final offset = metrics.getTangentForOffset((y / width1).clamp(0.0, 1.0) * metrics.length).position;

    return offset;

  }

}