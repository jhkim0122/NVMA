import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract class GraphPainter extends CustomPainter {
  Paint painter = Paint();
  Color color = Colors.cyanAccent;
  double strokeWidth = 1.0;
  bool isRect = false;
  bool isGrid = false;
  bool isXLog = false;
  bool isYLog = false;
  bool isNoiseType = true;
  double accentFreq = -1;
  late double xMax;
  List<double> samples = [];
  bool maxLabel = false;

  Offset pointOffset = Offset(0.0, 0.0);
  String pointValueStr = "";

  GraphPainter(){
    xMax = isNoiseType?2048:512;
    painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (samples == null) {
      return;
    }

    if(this.isRect){
      var rect = Rect.fromLTRB(0, size.height, size.width, 0);
      canvas.drawRect(rect, painter..color = Colors.black54);
    } else{
      var rrect = RRect.fromLTRBR(0, size.height, size.width, 0, Radius.circular(10.0));
      canvas.drawRRect(rrect, painter..color = Colors.black54);
    }

    if(this.isGrid){
      linePaint(canvas, size);
    }

    canvas.drawPath(path_skip(samples, size), painter..color = color);

    if(this.maxLabel) drawPointLabel(canvas, pointOffset, pointValueStr, Colors.black);
  }

  void drawPointLabel(Canvas canvas, Offset pointOffset, String pointStr, Color color){
    if(pointOffset.dx.isNaN || pointOffset.dy.isNaN) return;
    Paint pointPainter = Paint()
      ..strokeCap = StrokeCap.round
      ..color = color
      ..strokeWidth = 5.0
      ..isAntiAlias = true;

    canvas.drawPoints(PointMode.points, [pointOffset,], pointPainter); // draw Point

    TextSpan pointSpan = TextSpan(style: TextStyle(fontSize: 15.0, color: color, fontWeight: FontWeight.bold), text: pointStr);
    TextPainter textPainter = TextPainter(text: pointSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    double dx = pointOffset.dx - textPainter.width / 2;
    double dy = pointOffset.dy - (textPainter.height * 1.2);

    Offset offset = Offset(dx, dy);

    textPainter.paint(canvas, offset); // draw Text
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Path path_skip(List<double> samples, Size size, {List<double> xList});

  void linePaint(Canvas canvas, Size size){
    Paint linePainter = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black12.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    Paint accentPainter = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    double w = isXLog? (isNoiseType? size.width/log(xMax) : size.width/log(xMax)) : size.width *(500/xMax);
    if(xMax<10) w = size.width/10;
    else if(xMax<100) w = size.width*(5/xMax);
    else if(xMax<500) w = size.width*(50/xMax);
    double h = size.height/10;

    for(double i=w; i<size.width; i+=w){
      canvas.drawLine(Offset(i, 0.0), Offset(i, size.height), linePainter);
    }
    for(double i=h; i<size.height; i+=h){
      canvas.drawLine(Offset(0.0, i), Offset(size.width, i), linePainter);
    }

    if(accentFreq != -1){
      var freqStartOffset = isXLog? Offset(size.width*(log(accentFreq)/log(xMax)), 0) : Offset(size.width*(accentFreq/(xMax)), 0);
      var freqEndOffset = isXLog? Offset(size.width*(log(accentFreq)/log(xMax)), size.height) : Offset(size.width*(accentFreq/(xMax)), size.height);
      canvas.drawLine(freqStartOffset, freqEndOffset, accentPainter);

      TextSpan freqSpan = TextSpan(style: TextStyle(fontSize: 15.0, color: Colors.blueGrey.withOpacity(0.5), fontWeight: FontWeight.bold), text: accentFreq.toStringAsFixed(1)+'Hz');
      TextPainter tp = TextPainter(text: freqSpan, textDirection: TextDirection.ltr);
      tp.layout();

      double dx = freqEndOffset.dx - tp.width / 2;
      double dy = freqEndOffset.dy - tp.height;

      Offset offset = Offset(dx, dy);

      tp.paint(canvas, offset);
    }
  }

  void logConverter(List<double> xList){
    if(isXLog) {
      for (int i = 0; i < xList.length; i++) {
        xList[i] = xList[i] == 0 ? 0.0 : log(xList[i]) / ln10;
      }
    }
  }
}