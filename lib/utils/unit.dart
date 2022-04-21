import 'dart:math';


class Unit{
  static fromLinearToDecibel(List<double> data, levelBase, {startIndex = 0, endIndex = 0}) {
    endIndex = (endIndex <= 0)? data.length:endIndex;
    for (var i = startIndex; i < endIndex; ++i) {
      data[i] = 20 * log(data[i] / levelBase) / ln10;
    }
    return data;
  }

  static fromDecibelToLinear(List<double> data, levelBase, {startIndex = 0, endIndex = 0}) {
    endIndex = (endIndex <= 0)? data.length:endIndex;
    for (var i = startIndex; i < endIndex; ++i) {
      data[i] = levelBase * pow(10, data[i]/20);
    }
  }

  static double getRms(List<double> data, double startFreq, double endFreq, double deltaFreq, double levelBase, double lmsCorrection, {double startFreqOffset=0.0}){
    lmsCorrection = (lmsCorrection==0)?1.2:lmsCorrection;

    startFreq = (startFreq < startFreqOffset)?startFreqOffset : startFreq;
    Unit.fromDecibelToLinear(data, levelBase, startIndex: ((startFreq-startFreqOffset)/deltaFreq).floor(), endIndex: ((endFreq-startFreqOffset)/deltaFreq).ceil());

    var endIndex = (endFreq==0)? data.length : ((endFreq-startFreqOffset)/deltaFreq).round();
    var startIndex = ((startFreq-startFreqOffset)/deltaFreq).round();
    var rms = 0.0;
    for(var i = startIndex+1; i < endIndex-1; i++){
      rms += data.elementAt(i.toInt()) * data.elementAt(i.toInt());
    }

    var ratio = 1 - ((startFreq-startFreqOffset)/deltaFreq - (startIndex - 0.5));
    rms += data.elementAt(startIndex) * data.elementAt(startIndex) * ratio;

    ratio = ((endFreq==0)? data.length.toDouble() : ((endFreq-startFreqOffset)/deltaFreq)) - (endIndex - 0.5);
    if(endIndex > 0) rms += data.elementAt(endIndex-1) * data.elementAt(endIndex-1) * ratio;

    Unit.fromLinearToDecibel(data, levelBase, startIndex: ((startFreq-startFreqOffset)/deltaFreq).floor(), endIndex: ((endFreq-startFreqOffset)/deltaFreq).ceil());

    //TODO, check RMS correction for LMS compare test.
    return  20 * log(sqrt(rms)/lmsCorrection / levelBase) / ln10;
  }

  static fromVoltageToPhysical(List<double> data, sensitivity, {startIndex = 0, endIndex = 0}) {
    endIndex = (endIndex <= 0)? data.length:endIndex;
    for (var i = startIndex; i < endIndex; i++) {
      data[i] = data[i] * 1000 / sensitivity;
    }
    return data;
  }

  static smallestPowerOfTwo(int num){
    int ret = 2;
    while(ret < num){
      ret = ret*2;
    }
    return ret;
  }
}