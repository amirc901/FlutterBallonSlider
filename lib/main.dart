import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ballon Slider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ballon Slider'),
      debugShowCheckedModeBanner: false,
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
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: BallonSlider(),
      ),
    );
  }
}

class BallonSlider extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BallonSlider_State();
  }
}

class BallonSlider_State extends State<BallonSlider> {
  double lastHandleXPoint = 0;

  double handleX = 0;
  double handleY = 0;

  String valueText = "0";

  double handleBorderSize = 3;
  double handleBorderNormalSize = 3;
  double animHandleBorderNormalDistSize = -1;

  double handleSize = 4;
  double handleNormalSize = 4;
  double animDistHandleSize = 15;

  double handleAnimCurrentProgress = 0; // 0 - 1000
  double handleAnimMaxProgress = 10; // 0 - 1000

  int handleAnimEachUpdateTimeMs = 10;
  int handleAnimLastUpdateTime = 0;

  double ballonSize = 0;
  double ballonSizeNormalSize = 0;
  double ballonAnimDistSize = 50;

  double valueTextSize = 0;
  double valueNormalTextSize = 0;
  double valueTextDistSize = 20;

  double ballonAnimCurrentProgress = 0; // 0 - 1000
  double ballonAnimMaxProgress = 10; // 0 - 1000

  int ballonAnimEachUpdateTimeMs = 10;
  int ballonAnimLastUpdateTime = 0;

  double angle = 0;
  double goalAngle = 0;

  double xOffset = 0;

  Timer angleTimer;
  double width = 300;
  double height = 50;
  bool isHandleUnderPress = false;
  int handleOnPressTime = 0;
  int handleOnPressReleaseTime = 0;

  @override
  void initState() {
    super.initState();
    handleY = height / 2;

    ballonSize = ballonSizeNormalSize;
    valueTextSize = valueNormalTextSize;
  }

  void moveTheHandle(double x, double y) {
    if (isHandleUnderPress == false) return;

    var handleXValue = x;

    if (handleXValue > width) {
      handleXValue = width;
    }
    if (handleXValue < 0) {
      handleXValue = 0;
    }

    handleX = handleXValue;
  }

  @override
  void dispose() {
    super.dispose();
    angleTimer?.cancel();
  }

  int lastAngleUpdateTime = 0;
  int handleSizeUpdateDuration = 1000;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (detail) {
        var x = detail.localPosition.dx;
        var y = detail.localPosition.dy;

        if (x < handleX + (handleSize + handleBorderSize) &&
            x > handleX - (handleSize + handleBorderSize) &&
            y < handleY + (handleSize + handleBorderSize) &&
            y > handleY - (handleSize + handleBorderSize)) {
          isHandleUnderPress = true;
          handleOnPressTime = DateTime.now().millisecondsSinceEpoch;
          if ((angleTimer != null && angleTimer.isActive) == false) {
            angleTimer = Timer.periodic(Duration(milliseconds: 10), (pass) {
              var now = DateTime.now().millisecondsSinceEpoch;
              bool requiresSetState = false;

              if (goalAngle > 0) {
                goalAngle -= 1.5;
              } else if (goalAngle < 0) {
                goalAngle += 1.5;
              }

              if (now - lastAngleUpdateTime > 16) {
                requiresSetState = true;
              }

              if (lastHandleXPoint != handleX) {
                var handleMovement = handleX - lastHandleXPoint;
                lastHandleXPoint = handleX;

                valueText = (handleX * 100 / width).toInt().toString();

                goalAngle += (-1 * (handleMovement)).toInt();
                if (goalAngle > 90) {
                  goalAngle = 90;
                } else if (goalAngle < -90) {
                  goalAngle = -90;
                }
                requiresSetState = true;
              }

              if (goalAngle > -2 && goalAngle < 2) goalAngle = 0;

              xOffset = goalAngle / 2;

              if (now - lastAngleUpdateTime >= 16) {
                if ((angle - goalAngle).abs() > 2) angle = goalAngle;
                requiresSetState = true;
                lastAngleUpdateTime = now;
              }

              if (isHandleUnderPress &&
                  handleAnimCurrentProgress < handleAnimMaxProgress &&
                  (now - handleAnimLastUpdateTime) >= handleAnimEachUpdateTimeMs) {
                handleAnimCurrentProgress++;

                handleAnimLastUpdateTime = now;
                handleSize = handleNormalSize +
                    (animDistHandleSize * handleAnimCurrentProgress / handleAnimMaxProgress);

                handleBorderSize = handleBorderNormalSize +
                    (animHandleBorderNormalDistSize * handleAnimCurrentProgress / handleAnimMaxProgress);

                requiresSetState = true;
              } else if (isHandleUnderPress == false &&
                  handleAnimCurrentProgress != 0 &&
                  (now - handleAnimLastUpdateTime) >= handleAnimEachUpdateTimeMs) {
                //
                handleAnimCurrentProgress--;
                handleAnimLastUpdateTime = now;
                handleSize = handleNormalSize +
                    (animDistHandleSize * handleAnimCurrentProgress / handleAnimMaxProgress);

                handleBorderSize = handleBorderNormalSize +
                    (animHandleBorderNormalDistSize * handleAnimCurrentProgress / handleAnimMaxProgress);

                requiresSetState = true;
              }

              if (isHandleUnderPress &&
                  ballonAnimCurrentProgress < ballonAnimMaxProgress &&
                  (now - ballonAnimLastUpdateTime) >= ballonAnimEachUpdateTimeMs) {
                ballonAnimCurrentProgress++;
                ballonAnimLastUpdateTime = now;
                ballonSize = ballonSizeNormalSize +
                    (ballonAnimDistSize * ballonAnimCurrentProgress / ballonAnimMaxProgress);

                valueTextSize = valueNormalTextSize +
                    (valueTextDistSize * ballonAnimCurrentProgress / ballonAnimMaxProgress);

                requiresSetState = true;
              } else if (isHandleUnderPress == false &&
                  ballonAnimCurrentProgress != 0 &&
                  (now - ballonAnimLastUpdateTime) >= ballonAnimEachUpdateTimeMs) {
                //
                ballonAnimCurrentProgress--;
                ballonAnimLastUpdateTime = now;
                ballonSize = ballonSizeNormalSize +
                    (ballonAnimDistSize * ballonAnimCurrentProgress / ballonAnimMaxProgress);

                valueTextSize = valueNormalTextSize +
                    (valueTextDistSize * ballonAnimCurrentProgress / ballonAnimMaxProgress);

                requiresSetState = true;
              }

              if (isHandleUnderPress == false &&
                  goalAngle != 0 &&
                  handleAnimCurrentProgress == 0 &&
                  ballonAnimCurrentProgress == 0) {
                if (angleTimer.isActive) angleTimer.cancel();
                goalAngle = 0;
                handleSize = handleNormalSize;
                valueTextSize = valueNormalTextSize;
                ballonSize = ballonSizeNormalSize;
                handleBorderSize = handleBorderNormalSize;
              }

              if (requiresSetState) {
                setState(() {
                  angle = goalAngle;
                });
              }
            });
          }
        }
      },
      onPanEnd: (detail) {
        isHandleUnderPress = false;
        handleOnPressReleaseTime = DateTime.now().millisecondsSinceEpoch;
      },
      onPanCancel: () {
        isHandleUnderPress = false;
        handleOnPressReleaseTime = DateTime.now().millisecondsSinceEpoch;
      },
      onPanUpdate: (detail) {
        var x = detail.localPosition.dx;
        var y = detail.localPosition.dy;

        moveTheHandle(x, y);
      },
      child: CustomPaint(
        size: Size(width, height),
        painter: BallonSliderPainter(
          sliderHeight: 3,
          handleX: handleX,
          handleY: handleY,
          handleSize: handleSize,
          ballonSize: ballonSize,
          ballonAngle: angle,
          text: valueText,
          textSize: valueTextSize,
          handleBorderSize: handleBorderSize,
          xOffset: xOffset,
        ),
      ),
    );
  }
}

class BallonSliderPainter extends CustomPainter {
  final double handleX;
  final double handleY;
  final double handleSize;
  final double handleBorderSize;
  final double ballonAngle;
  final double ballonSize;
  final double sliderHeight;
  final double textSize;
  final String text;
  final double xOffset;

  Paint backgroundPaint = Paint()
    ..color = Colors.black12
    ..isAntiAlias = true;

  Paint foregroundPaint = Paint()
    ..color = Colors.deepPurpleAccent
    ..isAntiAlias = true;

  Paint handlePaint = Paint()
    ..color = Colors.white
    ..isAntiAlias = true;
  Paint handleBorderPaint;

  TextPainter ballonPainter;
  TextPainter valuePainter;

  BallonSliderPainter({
    this.sliderHeight,
    this.handleX,
    this.handleY,
    this.handleSize,
    this.ballonSize,
    this.ballonAngle,
    this.textSize,
    this.text,
    this.handleBorderSize,
    this.xOffset,
  }) {
    backgroundPaint.strokeWidth = sliderHeight;
    foregroundPaint.strokeWidth = sliderHeight;

    ballonPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(0xe800),
        style: TextStyle(
          color: Colors.deepPurpleAccent,
          fontFamily: 'Ballon',
          fontSize: ballonSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    handleBorderPaint = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeWidth = handleBorderSize * 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawSliderBackground(canvas, size);
    drawSliderForeground(canvas, size);
    drawSliderHandle(canvas, size);
    drawSliderBallon(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void drawSliderBackground(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), backgroundPaint);
  }

  void drawSliderForeground(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height / 2), Offset(handleX, size.height / 2), foregroundPaint);
  }

  void drawSliderHandle(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(handleX, handleY), handleSize, handlePaint);
    canvas.drawCircle(Offset(handleX, handleY), handleSize + (handleBorderSize), handleBorderPaint);
  }

  num degToRad(num deg) => deg * (pi / 180.0);

  void drawSliderBallon(Canvas canvas, Size size) {
    valuePainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: textSize,
          fontFamily: 'Ballon',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    canvas.save();

    ballonPainter.layout();
    valuePainter.layout();

    var valueW = valuePainter.width;
    var valueH = valuePainter.height;

    var ballonH = ballonPainter.height;
    var ballonW = ballonPainter.width;

    canvas.translate(handleX + xOffset, handleY - (handleSize / 2));

    canvas.rotate(degToRad(ballonAngle));
    canvas.translate(-(ballonW / 2), -(ballonH + handleSize));

    ballonPainter.paint(canvas, Offset.zero);
    valuePainter.paint(canvas, Offset((ballonW / 2) - (valueW / 2), (ballonH / 2) - (valueH / 2)));

//    ballonPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }
}
