import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathFormat{
  PathFormat();
  static String pathSlash = Platform.isAndroid? '/' : "\\";
  static String _windowsDirPath = " ";


  static getDirectoryPath(appName) async{
    if(Platform.isAndroid) {
      Directory directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    else if(Platform.isWindows) {
      if(_windowsDirPath != " ") {
        return _windowsDirPath;
      }
      else{
        Directory directory = await getApplicationDocumentsDirectory();
        _windowsDirPath =  directory.path+"\\"+appName;
        return _windowsDirPath;
      }
    }
  }

  static getExportPath(appName) async{
    if(Platform.isAndroid) return "/storage/emulated/0/" + appName;
    else return await getDirectoryPath(appName);
  }

  static getLoggedDate(path){
    var startIndex = path.lastIndexOf(pathSlash)+1;
    var tmp = path.substring(startIndex);
    tmp = tmp.substring(tmp.indexOf("_")+1);
    var formatTransformed = tmp.substring(0, 19).replaceAll("_",":");
    return DateTime.parse(formatTransformed);
  }

  static getLoggedMemo(path){
    var startIndex = path.lastIndexOf(pathSlash)+1;
    var tmp = path.substring(startIndex);
    tmp = tmp.substring(tmp.indexOf("_")+20);
    return tmp.contains("_") ? tmp.substring(tmp.indexOf("_")+1) : "";
  }
}