
import 'dart:convert';
import 'dart:io';

import '../../main.dart';
import '../../utils/PathFormat.dart';

enum SignalType{
  Noise, Vibration
}

abstract class Options{
  var map = Map();
  var jsonmap = Map();

  loadCommon(filename){
    PathFormat.getDirectoryPath(appName).then((directoryPath){
      final path = directoryPath + PathFormat.pathSlash + filename;
      var file = File(path);
      file.exists().then((isExist){
        if(isExist){
          map = jsonDecode(file.readAsStringSync());
          if(needReset()){
            map.clear();
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(map));
          }
          if(needUpdate()){
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(map));
          }
        }
        else{
          getDefaultOptions();
          file.writeAsStringSync(jsonEncode(map));
        }
      });

    });
  }

  loadLocal(path) {
    var file = File(path);
    if(file.existsSync()) {
      map = jsonDecode(file.readAsStringSync());
      if(needReset()) {
        map.clear();
        getDefaultOptions();
        file.writeAsStringSync(jsonEncode(map));
      }
      if(needUpdate()){
        getDefaultOptions();
        file.writeAsStringSync(jsonEncode(map));
      }
    } else{
      file.createSync();
      getDefaultOptions();
      file.writeAsStringSync(jsonEncode(map));
    }
  }

  loadJson(filename){
    PathFormat.getDirectoryPath(appName).then((directoryPath){
      final path = directoryPath + PathFormat.pathSlash + filename;
      var file = File(path);
      file.exists().then((isExist){
        if(isExist){
          jsonmap = jsonDecode(file.readAsStringSync());
          if(needReset()){
            jsonmap.clear();
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(jsonmap));
          }
          if(needUpdate()){
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(jsonmap));
          }
        }
        else{
          getDefaultOptions();
          file.writeAsStringSync(jsonEncode(jsonmap));
        }
      });
    });
  }

  loadAsync(filename) async {
      var directoryPath = await PathFormat.getDirectoryPath(appName);
      final path = directoryPath + PathFormat.pathSlash + filename;
      var file = File(path);
      var isExist = await file.exists();
        if(isExist){
          try{
          map = jsonDecode(file.readAsStringSync());
          }catch(_){}
          if(needReset()){
            map.clear();
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(map));
          }
          if(needUpdate()){
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(map));
          }
        }
        else{
          getDefaultOptions();
          file.writeAsStringSync(jsonEncode(map));
        }
  }

  loadJsonAsync(filename) async {
      var directoryPath = await PathFormat.getDirectoryPath(appName);
      final path = directoryPath + PathFormat.pathSlash + filename;
      var file = File(path);
      var isExist = await file.exists();
        if(isExist){
          try{
          jsonmap = jsonDecode(file.readAsStringSync());
          }catch(_){}
          if(needReset()){
            jsonmap.clear();
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(jsonmap));
          }
          if(needUpdate()){
            getDefaultOptions();
            file.writeAsStringSync(jsonEncode(jsonmap));
          }
        }
        else{
          getDefaultOptions();
          file.writeAsStringSync(jsonEncode(jsonmap));
        }
  }

  saveCommon(filename) async{
    var directoryPath = await PathFormat.getDirectoryPath(appName);
    final path = directoryPath + PathFormat.pathSlash + filename;
    var file = File(path);
    if(await file.exists()) {
    try{await file.delete();}catch(e){}
    await file.create();
    }
    file.writeAsStringSync(jsonEncode(map));
  }

  saveLocal(path) async{
    var file = File(path);
    if(await file.exists()) {
    await file.delete();
    await file.create();
    }
    file.writeAsStringSync(jsonEncode(map));
  }

  saveJson(filename) async
  {
    var directoryPath = await PathFormat.getDirectoryPath(appName);
    final path = directoryPath + PathFormat.pathSlash + filename;
    var file = File(path);
    if(await file.exists()) {
    await file.delete();
    await file.create();
    }
    file.writeAsStringSync(jsonEncode(jsonmap));
  }

  getDefaultOptions();
  needUpdate(){
    return false;
  }
  needReset(){
    return false;
  }
}

//TODO, make factory