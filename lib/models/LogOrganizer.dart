import 'dart:io';

import '../utils/PathFormat.dart';

class LogOrganizer{
  String appDocPath;
  String vibPath;
  String micPath;
  String fileName;
  String directoryPath = "";
  LogOrganizer(this.appDocPath, {this.vibPath = "", this.micPath = "", this.fileName = ""}){
    if(fileName == ""){
      var now = DateTime.now();
      var timeString = now.toString().replaceAll(':', '_').substring(0, now.toString().lastIndexOf('.'));
      directoryPath = appDocPath + PathFormat.pathSlash + timeString;
    } else directoryPath = appDocPath + PathFormat.pathSlash + fileName;
    Directory directory = Directory(directoryPath);
    directory.createSync();

    try{File(appDocPath+ PathFormat.pathSlash + "sensors.json").copySync(directory.path + PathFormat.pathSlash + "sensors.json");}catch(_){}
    try{File(appDocPath+ PathFormat.pathSlash + "vehicle.json").copySync(directory.path + PathFormat.pathSlash + "vehicle.json");}catch(_){}

    try{File(vibPath).renameSync(directory.path + PathFormat.pathSlash + vibPath.substring(vibPath.indexOf("btsensor")));}catch(_){}
    try{File(micPath).renameSync(directory.path + PathFormat.pathSlash + "mic_stream");}catch(_){}
  }
}


