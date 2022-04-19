import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'GraphPainter.dart';

class XYComboGraphPainter extends GraphPainter {
  List<List<List<double>>> seriesList = [];
  double yMax = 1.0;
  double yMin = 0.0;
  late String yUnit;
  bool isYAuto = true;

  List<double> yMaxList = [1.0];
  List<double> yMinList = [0.0];
  late List<String> yUnitList;
  late Map<double, List<int>> yMaxIndexMap;

  late bool currentLabel = false;

  Offset maxOffset = Offset(0.0, 0.0);
  String maxValueStr = "";
  Offset currentOffset = Offset(0.0, 0.0);
  String currentValueStr = "";
  late List<String> idList;

  @override
  Path path_skip(List<double> samples, Size size, {List<double> xList = const []}){
    assert(samples != null);
    // assert(samples.length < size.width);

    final bottom = size.height;
    List<Offset> points = [];
    double maxPointValue = 0.0;

    logConverter(xList);

    final numPoints = samples.length; //point의 갯수
    var width = xList[xList.length - 1];
    final t = size.width / width; // pixel 간격

    for (var _i = 0; _i < numPoints; _i++) {
      var d = samples.elementAt(_i);
      if(maxPointValue<=d) maxPointValue = d;
      d = (d - yMin) / (yMax - yMin);
      if(d > 1.0) d = 1;
      if(d < 0.0) d = 0.0;
      if(_i>0){ if(xList[_i] < 0) xList[_i] = 0.0;}
      if(_i==0) points.add(Offset(t*xList[0],bottom));
      points.add(Offset(t * xList[_i], bottom - bottom * d));
    }

    final path = Path();
    path.moveTo(0, bottom);
    points.forEach((o) => path.lineTo(o.dx, o.dy));
    path.lineTo(size.width, bottom);

    if(this.maxLabel) {
      maxOffset = Offset(size.width, size.height);
      for (var i = 1; i < points.length; i++) {
        if (points[i].dy < maxOffset.dy) maxOffset = points[i];
      }
      maxValueStr = maxPointValue.toStringAsFixed(1);
    }

    if(this.currentLabel){
      currentOffset = points.last;
      currentValueStr = samples.last.toStringAsFixed(1);
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size){

    if(isGrid) linePaint(canvas, size);

    if (seriesList.length <1 || seriesList.first.length < 1) {
      if(isRect){
        var rect = Rect.fromLTRB(0, size.height, size.width, 0);
        canvas.drawRect(rect, painter..color = Colors.black);
      } else{
        var rrect = RRect.fromLTRBR(0, size.height, size.width, 0, Radius.circular(10.0));
        canvas.drawRRect(rrect, painter..color = Colors.black);
      }
      if(!isYAuto) drawYMinMax(canvas, size);
      return;
    }

    drawYMinMax(canvas, size);

    seriesList.forEach((data){
      if(data.length > 0 && data.first.length > 0){
        var i = seriesList.indexOf(data);
        if(yMaxIndexMap != null) {
          yMax = 6000; // default(rpm)
          for(int v=0; v<yMaxIndexMap.length; v++){
            if(yMaxIndexMap.values.elementAt(v).contains(i)) {
              yMax = yMaxIndexMap.keys.elementAt(v);
              if(yMinList.length > v) yMin = yMinList.elementAt(v);
            }
          }
        }
        var color = i>8? Colors.primaries.elementAt( ((i-9)*2 +1)).shade800 :
        Colors.primaries.elementAt((i*2)).shade300;
        canvas.drawPath(path_skip(data.first, size, xList: data.last), painter..color = color); // index max 17
        if(this.maxLabel && maxOffset != Offset(size.width, size.height)) drawPointLabel(canvas, maxOffset, maxValueStr, color);
        if(this.currentLabel && currentOffset != Offset(0.0, 0.0)) drawPointLabel(canvas, currentOffset, currentValueStr, color);
      }
    });

    if(isRect){
      var rect = Rect.fromLTRB(0, size.height, size.width, 0);
      canvas.drawRect(rect, painter..color = Colors.black);
    } else{
      var rrect = RRect.fromLTRBR(0, size.height, size.width, 0, Radius.circular(10.0));
      canvas.drawRRect(rrect, painter..color = Colors.black);
    }
  }

  void drawYMinMax(Canvas canvas, Size size){
    if(isYAuto){
      seriesList.forEach((data){
        if(data.length > 1 && data.first.length > 1) {
          var dataMax = data.first.reduce(max);
          if (dataMax > yMax) yMax = dataMax;
        }
      });
      if(yMax < 1) yMax = 1;
      else if (yMax > 1 && yMax<10) yMax = 10;
      else if(yMax > 10 && yMax < 100) yMax = 100;
      else if(yMax > 100){
        double i=100;
        while(yMax%100 != 0) {
          if (yMax > i && yMax < i + 100) yMax = i + 100;
          i+=100;
        }
      }
    }

    if(yMaxList.length > 1){
      for(int m=0; m<yMaxList.length; m++){
        double max = yMaxList.elementAt(m);
        double min = yMinList.elementAt(m);
        double middle = max<10? max/2:(max-min)/2;
        String maxStr = max.toStringAsFixed(0);
        String minStr = min.toStringAsFixed(0)+yUnitList.elementAt(m)??"";
        String middleStr = middle<10? middle.toStringAsFixed(1):middle.toStringAsFixed(0);
        if(minStr.length <= maxStr.length){
          if(min<0){
            minStr = " "+minStr;
          } else{
            String blank = "";
            for(int t=0; t<maxStr.length-minStr.length; t++) blank+="  ";
            minStr = blank + minStr;
          }
        }
        if(minStr.length <= maxStr.length && min<0){minStr = " "+minStr;}
        if(middleStr.length < maxStr.length){
          String blank = "";
          for(int t=0; t<maxStr.length-middleStr.length; t++) blank+="  ";
          middleStr = blank + middleStr;
        }

        Paint linePainter = Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black45
          ..strokeWidth = 1.0
          ..isAntiAlias = true;
        if(m==0){
          double lineX = 0;
          double lineWidth = lineX-4;
          canvas.drawLine(Offset(lineX, 0.0), Offset(lineWidth, 0.0), linePainter);
          canvas.drawLine(Offset(lineX, size.height), Offset(lineWidth, size.height), linePainter);
          canvas.drawLine(Offset(lineX, size.height/2), Offset(lineWidth, size.height/2), linePainter);
        } else if(m==1){
          double lineX = size.width+4;
          double lineWidth = lineX-4;
          canvas.drawLine(Offset(lineX, 0.0), Offset(lineWidth, 0.0), linePainter);
          canvas.drawLine(Offset(lineX, size.height), Offset(lineWidth, size.height), linePainter);
          canvas.drawLine(Offset(lineX, size.height/2), Offset(lineWidth, size.height/2), linePainter);
        }

        TextSpan yMaxSpan = TextSpan(
          style: TextStyle(fontSize: 12.0, color: Colors.black),
          text: maxStr,
        );
        TextPainter maxPainter = TextPainter(text: yMaxSpan, textDirection: TextDirection.ltr);
        maxPainter.layout();
        double height = 14;
        double dx = m==0? -maxPainter.width-5 : size.width+2;
        double dy = -(height*0.2);
        Offset offset = Offset(dx, dy);
        if(max>min) maxPainter.paint(canvas, offset);

        TextSpan yMinSpan = TextSpan(
          style: TextStyle(fontSize: 12.0, color: Colors.black),
          text: minStr,
        );
        TextPainter minPainter = TextPainter(text: yMinSpan, textDirection: TextDirection.ltr);
        minPainter.layout();
        dy = size.height - height/1.2;
        offset = Offset(dx, dy);
        if(max>min) minPainter.paint(canvas, offset);

        TextSpan yMiddleSpan = TextSpan(
          style: TextStyle(fontSize: 12.0, color: Colors.black),
          text: middleStr,
        );
        TextPainter middlePainter = TextPainter(text: yMiddleSpan, textDirection: TextDirection.ltr);
        middlePainter.layout();
        dy = size.height/2 - height/2;
        offset = Offset(dx, dy);
        if(max>middle && min<middle) middlePainter.paint(canvas, offset);
      }
    }
    else{
      TextSpan yMaxSpan = TextSpan(
        style: TextStyle(fontSize: 12.0, color: Colors.black),
        text: yMax.toStringAsFixed(0),
      );
      TextPainter maxPainter = TextPainter(text: yMaxSpan, textDirection: TextDirection.ltr);
      maxPainter.layout();
      double dx = -(maxPainter.width*1.1);
      double dy = -(maxPainter.height*0.2);
      Offset offset = Offset(dx, dy);
      if(yMax>yMin) maxPainter.paint(canvas, offset);

      TextSpan yMinSpan = TextSpan(
        style: TextStyle(fontSize: 12.0, color: Colors.black),
        text: yMin.toStringAsFixed(0)+(yUnit??" "),
      );
      TextPainter minPainter = TextPainter(text: yMinSpan, textDirection: TextDirection.ltr);
      minPainter.layout();
      dx = -(minPainter.width*1.1);
      dy = size.height - minPainter.height/1.2;
      offset = Offset(dx, dy);
      if(yMax>yMin) minPainter.paint(canvas, offset);

      double yMiddle = yMax<10? yMax/2:(yMax+yMin)/2;
      TextSpan yMiddleSpan = TextSpan(
        style: TextStyle(fontSize: 12.0, color: Colors.black),
        text: yMiddle<10? yMiddle.toStringAsFixed(1):yMiddle.toStringAsFixed(0),
      );
      TextPainter middlePainter = TextPainter(text: yMiddleSpan, textDirection: TextDirection.ltr);
      middlePainter.layout();
      dx = -(middlePainter.width*1.1);
      dy = size.height/2 - middlePainter.height/2;
      offset = Offset(dx, dy);
      if(yMax>yMiddle && yMin<yMiddle) middlePainter.paint(canvas, offset);
    }
  }
}

Widget getLegendButtons(List<String> idList, List<bool> onOffList) {
  List<Widget> buttonsList = [];
  if(idList.length < 1) return SizedBox(height:0, width:0);
  else {
    idList.forEach((id){
      var i = idList.indexOf(id);
      var color = i>8? Colors.primaries.elementAt( ((i-9)*2 +1)).shade800 :
      Colors.primaries.elementAt((i*2)).shade300;
      buttonsList.add(
        Container(
            height:30,
            margin: EdgeInsets.all(8),
            decoration: new BoxDecoration(
                border: Border.all(color:onOffList[i]? color : color.withOpacity(0.3), width:2),
                borderRadius: BorderRadius.circular(10)
            ),
            child: FlatButton(
              child: Text(id, style: TextStyle(fontSize:13.0, color:onOffList[i]?Colors.black:Colors.grey.withOpacity(0.5))),
              onPressed: () {
                onOffList[i] = !onOffList[i];
              },
            )
        ),
      );
    });
    return Padding(
        padding: EdgeInsets.only(left:10),
        child:Wrap(children: buttonsList));
  }
}