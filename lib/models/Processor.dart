import 'dart:typed_data';

class Processor {
  var _dataDestination;
  bool doSend = false;
  var processedValue;

  setDestination(destination){
    _dataDestination = destination;
  }

  process(key, value){
    processedValue = value;
  }

  sendToDestination(key, value, {valueNum = 4}){
    _dataDestination.send(key, value, valueNum:valueNum);
  }

  getProcessedDataModel(dataModel){
    return dataModel;
  }
}

class ConvertToByteDataProcessor extends Processor{

  @override
  process(key, value){
    processedValue = ByteData(4);
    processedValue.setInt32(0, value);
    if(doSend) sendToDestination(key, processedValue);
  }

  processFloat(key, value){
    processedValue = ByteData(4);
    processedValue.setFloat32(0,value);
    if(doSend) sendToDestination(key, processedValue);
  }

  process2Byte(key, value){
    processedValue = ByteData(2);
    processedValue.setInt16(0, value, Endian.little);
    if(doSend) sendToDestination(key, processedValue, valueNum: 2);
  }

}