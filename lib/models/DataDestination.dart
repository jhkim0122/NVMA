import 'dart:collection';

import 'dart:io';

import 'dart:typed_data';

import '../utils/PathFormat.dart';

abstract class DataDestination {
  var _buffer;
  var _timestamps;

  initSend();
  send(key, value, {valueNum = 4});
  clear() {
    _buffer.clear();
    _timestamps.clear();
  }
}

class Logger extends DataDestination {
  var logFile;
  var directory;
  var appName;
  String postFix = "";

  Logger() {
    _buffer = Queue<int>();
    _timestamps = Queue<double>();
  }

  @override
  initSend() async{
    directory = Directory(await PathFormat.getDirectoryPath(appName));
    if (!directory.existsSync())  directory.createSync();
    final path = directory.path + genFileName();
    logFile = File(path);
    if(await logFile.exists()) {
      //TODO, edit file name.
      await logFile.delete();
      await logFile.create();
    }
    return logFile;
  }

  @override
  send(key, value, {valueNum = 4}) {
    _buffer.addAll(value.buffer.asUint8List(0, valueNum));
  }

  write() async{
    final file = await logFile;
    file.writeAsBytesSync(_buffer.toList(), mode: FileMode.append);
  }

  genFileName({addPostFix=""}){
    var now = DateTime.now();
    var timeString = now.toString().replaceAll(':','_').substring(0, now.toString().lastIndexOf('.'));
    return PathFormat.pathSlash + timeString + addPostFix + postFix;
  }

  String changeFileName({addPostFix=""}){
    String ret = directory.path+genFileName(addPostFix: addPostFix);
    logFile.renameSync(ret);
    return ret;
  }

  getBaseName(){
    return logFile.path.substring(0, logFile.path.length - postFix.length);
  }

}