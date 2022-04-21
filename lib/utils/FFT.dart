import 'dart:math';
import 'dart:typed_data';

import 'package:nvma/utils/windowing.dart';
import 'package:smart_signal_processing/smart_signal_processing.dart';



class fft{
  static List<double> process(List<double> input, {int paddedWindowSize = 0, WindowingMethod windowingMethod = WindowingMethod.Hann}){
    var window = WindowingFactory.create(windowingMethod);
    var windowed = window.process(input);
    var correction = 1.5;

    //zero padding, if needed
    if(paddedWindowSize != 0){
      //if(paddedWindowSize != windowed.length) correction = 1.0;
      while(windowed.length < paddedWindowSize){
        windowed.add(0.0);
      }
    }

    var real = Float64List.fromList(windowed);
    var imag = Float64List(real.length);

    try{
      FFT.transform(real, imag);
    }catch(error){
      print(real.length);
      print("error occurred!");
      //TODO, return empty queue.
      return input;
    }

    for(var i = 0; i < real.length~/2; ++i){
      //TODO, check autopower?
      real[i] = sqrt(real[i]*real[i] + imag[i]*imag[i]) * window.getAmplitudeCorrectionFactor()*correction/(input.length);
    }
    return new List<double>.from(real.sublist(0,real.length~/2));
  }
}