import 'dart:ui';

import 'GraphPainter.dart';

class RealtimeWavePainter extends GraphPainter {
  var scale = 1.0;
  double offset = 0.0;
  double maxValue = 1.0;

  RealtimeWavePainter();

  // TODO, not sampling. skip points that overlaps.
  @override
  path_skip(List<double> samples, Size size, {var xList =const []}) {
    final middle = size.height / 2 + offset;

    List<Offset> points = [];

    final numPoints = samples.length;
    final t = size.width / numPoints;

    double pointValue = 0.0;
    if(size.width < numPoints){
      final delta = numPoints / size.width;
      for(var _x = 0, _i = 0.0; _x < size.width; _x++, _i+=delta){
        var min = samples.elementAt(_i.floor());
        var max = min;
        for(var _subI = _i.floor(); _subI < (_i + delta).floor() && _subI < numPoints;_subI++){
          final value = samples.elementAt(_subI);
          if(pointValue<=value) pointValue = value;
          if(value < min) min = value;
          if(value > max) max = value;
        }
        max = max * scale / maxValue;
        if(max > 1.0) max = 1.0;
        if(max < -1.0) max = -1.0;

        min = min * scale / maxValue;
        if(min > 1.0) min = 1.0;
        if(min < -1.0) min = -1.0;

        points.add(Offset(_x.toDouble(), middle - middle * min));
        points.add(Offset(_x.toDouble(), middle - middle * max));
      }
    }else{
      for (var _i = 0; _i < numPoints; _i++) {
        var d = samples.elementAt(_i);
        if(pointValue<=d) pointValue = d;
        d = d*scale/maxValue;
        if(d > 1.0) d = 1.0;
        if(d < -1.0) d = -1.0;
        points.add(Offset(t * _i, middle - middle * d));
      }
    }

    final path = Path();
    path.moveTo(0, middle);
    points.forEach((o) => path.lineTo(o.dx, o.dy));
    path.lineTo(size.width, middle);

    pointOffset = Offset(size.width, size.height);

    for(var i=1; i<points.length; i++){
      if(points[i].dy < pointOffset.dy) pointOffset = points[i];
    }
    pointValueStr = pointValue.toStringAsFixed(1);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(RealtimeWavePainter oldDelegate) {
    return true;
  }
}