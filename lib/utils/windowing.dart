import 'dart:math';

enum WindowingMethod {
  Hann, tbd
}

class WindowingFactory{
  static Windowing create(WindowingMethod window){
    switch(window){
      case(WindowingMethod.Hann):{
        return HannWindowing();
      }
      //TODO, add other windowing methods.
      default:{
        assert(false);
        return HannWindowing();
      }
    }
  }
}

abstract class Windowing{
  List<double> process(List<double> data);
  double getEnergyCorrectionFactor();
  double getAmplitudeCorrectionFactor();
}


class HannWindowing extends Windowing{
  @override
  List<double> process(List<double> data){
    List<double> ret = List.from(data);
    for (var i = 0; i < data.length; ++i) {
      ret[i] = data[i] * sin(pi * i / data.length) *
          sin(pi * i / data.length);
    }
    return ret;
  }

  @override
  double getEnergyCorrectionFactor(){
    return sqrt(8.0 / 3.0);
  }


  @override
  double getAmplitudeCorrectionFactor(){
    return 2.0;
  }
}
