import 'dart:typed_data';

import 'Processor.dart';

abstract class Parser {
  var sensorDataModel;
  var _timestamp = 0;
  var _processor;
  var blockSize = -1;
  List<int> _buffer = [];
  bool doSend = false;

  Parser(dataModel) {
    sensorDataModel = dataModel;
  }

  setProcessor(processor){
    _processor = processor;
  }

  _parseBlock(dataInput, startIndex, sending);

  parse(dataInput){
    assert(blockSize != -1);

    var ret = 0;
    int i = 0;

    _buffer.addAll(dataInput);
    var bufferUint8 = Uint8List.fromList(_buffer);

    while( (i + blockSize) <=  bufferUint8.buffer.lengthInBytes ){
      var sizeRead = _parseBlock(bufferUint8, i, doSend);
      i += blockSize;
      i = sizeRead + i;
    }
    _buffer = _buffer.sublist(i);

    return ret;
  }

  startSendingData() {
    doSend = true;
  }

  stopSendingData() {
    doSend = false;
  }

  reset(){
    doSend = false;
    _buffer.clear();
  }
}

class NVDSDataParser extends Parser {
  int numChannels = 0;
  var loggedSensorDataStartTimestamp = 0;
  var indexTable = [];
  var sensorsMap;

  NVDSDataParser(dataModel) : super(dataModel);

  @override
  reset(){
    _buffer.clear();
    indexTable.clear();
  }

  setBlockSize(sensorOptionsMap) {
    sensorsMap = sensorOptionsMap;
    if(sensorsMap.containsKey('channels')) numChannels = sensorsMap['channels'];
    if(!sensorsMap.containsKey('ai1_samplingRate')){
      blockSize = 968;
      // 모든 채널의 sampling rate = 20kHz. blockSize = (2 + 20*12)*4 = 968
    } else{
      blockSize = 2;
      for(int i = 1; i <= numChannels; ++i){
        int _samplingRate = sensorOptionsMap['ai'+i.toString()+'_samplingRate'];
        blockSize += (sensorOptionsMap['ai'+i.toString()+'_position'] == "None" ? 1 : _samplingRate);
      }
      blockSize = blockSize * 4;
    }
    getIndexTable();
  }

  getIndexTable(){
    if(!sensorsMap.containsKey('ai1_samplingRate')){
      for(var i = 0; i < 20; ++i){
        for(var j = 0; j < numChannels; ++j){
          indexTable.add(j);
        }
      }
    } else{
      for(var i = 0; i < 100; ++i){
        for(var j = 0; j < numChannels; ++j){
          var samplingRate = sensorsMap['ai'+(j+1).toString()+'_position'] =="None"? 1 : (sensorsMap['ai'+(j+1).toString()+'_samplingRate']?? 20);
          if(i % (100/samplingRate) == 0){
            indexTable.add(j);
          }
        }
      }}
  }

  _insertToSensorTimeDataModel(key, value){
      if(!sensorDataModel.containsKey(key)){
        return ;
      } else {
        sensorDataModel[key].add(value);
      }
  }

  @override
  int _parseBlock(dataInput, startIndex, sending){
    _processor.doSend = doSend;
    if(indexTable.isEmpty) getIndexTable();

    _timestamp = dataInput.buffer.asByteData().getUint32(startIndex+0);
    if(doSend) _processor.process('', _timestamp);
    var state = dataInput.buffer.asByteData().getUint32(startIndex+4);
    if(doSend) _processor.process('', state);

    var value;
    var i = 2;
    for( var j in indexTable){
      value = dataInput.buffer.asByteData().getFloat32(startIndex + i * 4, Endian.big);
      if(doSend) _processor.processFloat('', value);
      ++i;
      _insertToSensorTimeDataModel('ai' + (j+1).toString(), value);
    }

    return 0;
  }
  
}

class Esp32AdxlParser extends Parser {
  var startI = 0;
  var isError = false;
  var loggedSensorDataStartTimestamp = 0;

  Esp32AdxlParser(start, dataModel) : super(dataModel){
    blockSize = 64;
    startI = start;
  }


  _insertToSensorTimeDataModel(key, value){
    if(!sensorDataModel.containsKey(key)){
      return ;
    } else {
      sensorDataModel[key].add(value);
    }
  }

  @override
  _parseBlock(dataInput, startIndex, sending) {
    _processor.doSend = doSend;
    var firstTime = _timestamp;
    var secondTime = 0;

    var sensitivity = 1632.625; // (m/s2 / LSB)

    for(int i = 0; i < 10; ++i){
      var value = dataInput.buffer.asByteData().getInt16(startIndex+i*6, Endian.little);
      _insertToSensorTimeDataModel('di'+(startI+1).toString(), value.toDouble()/sensitivity);
      if(doSend) _processor.process('', value);
      value = dataInput.buffer.asByteData().getInt16(startIndex+i*6+2, Endian.little);
      _insertToSensorTimeDataModel('di'+(startI+2).toString(), value.toDouble()/sensitivity);
      if(doSend) _processor.process('', value);
      value = dataInput.buffer.asByteData().getInt16(startIndex+i*6+4, Endian.little);
      _insertToSensorTimeDataModel('di'+(startI+3).toString(), value.toDouble()/sensitivity);
      if(doSend) _processor.process('', value);
    }


    _timestamp = dataInput.buffer.asByteData().getUint32(startIndex+60, Endian.little);
    if(loggedSensorDataStartTimestamp==0) loggedSensorDataStartTimestamp = _timestamp;
    if(doSend) _processor.prepareLogToWrite('timestamp', _timestamp);

    if(firstTime == 0) firstTime = _timestamp;
    else{secondTime = _timestamp;}

    if(firstTime!=0 && secondTime!=0) {
      var timegap = secondTime - firstTime;
      if(timegap>4 || timegap<0) {
        isError = true;
        print("Not a continuous data");
        print(timegap);
      }
      else isError = false;
    }

    return 0;
  }

  @override
  reset(){
    isError = false;
    _timestamp = 0;
    _buffer.clear();
  }
}

class InternalMicParser extends Parser {

  var _sensitivity = 1.0/32768;

  InternalMicParser(dataModel) : super(dataModel){
    blockSize = 2;
  }

  @override
  _parseBlock(dataInput, startIndex, sending) {
    var value = dataInput.buffer.asByteData().getInt16(startIndex, Endian.little);
    sensorDataModel["internal mic"].add(value*_sensitivity);
    if(doSend) _processor.process2Byte('', value);

    return 0;
  }

}

