


// map['ai1_type'] = noise
// map['ai1_sensitivity'] = xxx
// map['ai1_samplingRate'] = xx (k생략)

// map['diN'] = "disconnected" or Sensor Name
// map['diN_type'] = vibration
// map['diN_sensitivity'] = xxx
// map['diN_samplingRate'] = xx

import 'options.dart';

List<int> analogSamplingRateValues = [1024, 2048, 4096, 8192, 16384, 32768, 65536];
List<int> vibrationSamplingRateValues = [1000, 2000, 4000];
List<int> micSamplingRateValues = [2000, 4000, 8000, 16000, 24000, 48000];

class SensorOptions extends Options{

  save() async {
    saveCommon("sensors.json");
  }

  load() {
    loadCommon("sensors.json");
  }

  @override
  getDefaultOptions() {
    for(int i = 1; i < 2; ++i){
      map['ai'+i.toString()+'_type'] = "Noise";
      map['ai'+i.toString()+'_sensitivity'] = 45.0;
      map['ai'+i.toString()+'_samplingRate'] = 48;
    }
  }

  isValid(btCons){
    bool floorZ = false;
    for(int i = 1; i < 13; ++i){
      if(map['ai'+i.toString()+'_position'] == "Floor Z") floorZ = true;
    }

    int i=1;
    bool isDigitalConnected = false;
    btCons.forEach((con){
      isDigitalConnected = isDigitalConnected || (con.isActivate && map.containsKey('di'+(i*3).toString()+'_type'));
      i++;
    });
    return floorZ || isDigitalConnected;
  }

  @override
  needReset() {
    return map.containsKey('ai2_type');
  }

}