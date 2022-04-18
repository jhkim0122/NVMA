import 'dart:collection';

class DataModel{
  var data;
  add(value, {key}){
    data.add(value);
  }
  getData(){
    return data;
  }
}

class RealtimeSensorTimeDataModel extends DataModel{
  var originalDataSamplingRate = 20000.0;
  var _samplingRate = 20000.0;
  var _delta = 1.0;
  var _samplingCounter = 0.0;
  var maxLength = 1000;
  RealtimeSensorTimeDataModel(this._samplingRate, this.originalDataSamplingRate, this.maxLength){
    data = Queue<double>();
    _delta = originalDataSamplingRate / _samplingRate;
    _samplingCounter = _delta;
  }

  @override
  add(value,{key}){
    _samplingCounter--;
    if(_samplingCounter < 1) {
      while(_samplingCounter<0){
        data.add(value);
        _samplingCounter += _delta;

        if(maxLength<data.length) data.removeFirst();
      }
    }
  }
  getSamplingRate(){
    return _samplingRate;
  }
  setSamplingRate(input){
    _samplingRate = input;
  }
  setOriginalDataSamplingRate(samplingRate){
    originalDataSamplingRate = samplingRate;
    data.clear();
    _delta = originalDataSamplingRate / _samplingRate;
    _samplingCounter = _delta;
  }
  getDelta(){
    return _delta;
  }
}