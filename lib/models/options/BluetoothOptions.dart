
import 'options.dart';

class BluetoothOptions extends Options{

  load() async{
    await loadAsync("bluetooth.json");
  }

  save() async {
    saveCommon("bluetooth.json");
  }

  @override
  getDefaultOptions() {

  }

  @override
  needReset(){
    bool isNotAddressKey = false;
    map.keys.forEach((key){
      isNotAddressKey = isNotAddressKey || key.contains('_');
    });
    return isNotAddressKey;
  }
}