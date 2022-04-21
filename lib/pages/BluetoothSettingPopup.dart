import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:nvma/models/DataModel.dart';

import '../main.dart';
import '../models/DataDestination.dart';
import '../models/DataSource.dart';
import '../models/Parser.dart';
import '../models/Processor.dart';
import '../models/options/BluetoothOptions.dart';
import '../models/options/SensorOptions.dart';

class BluetoothSettingPopup extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final List<BlueConnection> btConnectionList;
  final TcpConnection tcpConnection;
  final Map sensorTimeDataModelsMap;
  final BluetoothOptions btOptions;
  final SensorOptions sensorOptions;
  final bool checkAvailability;
  const BluetoothSettingPopup(this.btConnectionList, this.tcpConnection, this.sensorTimeDataModelsMap, this.btOptions, this.sensorOptions,
      {this.checkAvailability = true, key}):super(key:key);

  @override
  _BluetoothSettingPopupState createState() => _BluetoothSettingPopupState();
}

class _BluetoothSettingPopupState extends State<BluetoothSettingPopup> {
  List<_DeviceWithAvailability> devices = [];

  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();

    widget.btOptions.load();

    _isDiscovering = widget.checkAvailability;

    _startDiscovery();
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() async{
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices.map((device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
        ).toList();
          _isDiscovering = false;
      });
        return;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices.map((_device) =>
        BluetoothDeviceListEntry(
          device: _device.device,
            enabled: _device.availability == _DeviceAvailability.yes,
            onTap: () async {
              bool isContain = false;

              widget.btConnectionList.forEach((con) async{
                if(con.address == _device.device.address) {
                  if(con.name != _device.device.name) {
                    widget.btOptions.map.remove(con.address);
                    con.name = _device.device.name!;
                  }
                  isContain = true;

                  widget.btOptions.map[_device.device.address] = _device.device.name;
                  widget.btOptions.save();
                  Navigator.pop(context);
                  setState(() {});
                }
              });
              if(!isContain){
                BlueConnection btCon = BlueConnection();
                btCon.setSensorOptions(widget.sensorOptions);
                btCon.name = _device.device.name!;
                btCon.address = _device.device.address;
                Esp32AdxlParser parser = Esp32AdxlParser((widget.btConnectionList.length*3), widget.sensorTimeDataModelsMap);
                parser.setProcessor(ConvertToByteDataProcessor()..setDestination(Logger(appName, postFix:"_btsensor_"+_device.device.name!)));
                btCon.setParser(parser);
                for(int i=1; i<4; i++){
                  widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()] = "disconnected";
                  widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()+"_type"] = "Vibration";
                  widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()+"_sensitivity"] = 26122.0;
                  widget.sensorTimeDataModelsMap['di'+((widget.btConnectionList.length*3)+i).toString()] = RealtimeSensorTimeDataModel(4096, 2048);
                  widget.sensorTimeDataModelsMap['di'+((widget.btConnectionList.length*3)+i).toString()].setOriginalDataSamplingRate(4000.0);
                  if(i==1) {
                    widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()+"_position"] = "X";
                  } else if(i==2) {
                    widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()+"_position"] = "Y";
                  } else if(i==3) {
                    widget.sensorOptions.map['di'+((widget.btConnectionList.length*3)+i).toString()+"_position"] = "Z";
                  }
                }
                widget.btConnectionList.add(btCon);
                widget.sensorOptions.save();

                widget.btOptions.map[_device.device.address] = _device.device.name;
                widget.btOptions.save();
                Navigator.pop(context);
                setState(() {});
              }
            },
          )).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bluetooth', style:TextStyle(color: Colors.black)),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.replay_rounded, color: Colors.black),
                  onPressed: _restartDiscovery,
                ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: (){ FlutterBluetoothSerial.instance.openSettings(); },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: ListView(children: list),
    );
  }
}

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({Key? key,
    required BluetoothDevice device,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(key: key,
          onTap: onTap,
          onLongPress: onLongPress,
          enabled: enabled,
          leading: const Icon(Icons.devices, color:Colors.black),
          title: Text(device.name ?? "Unknown device", style: const TextStyle(color: Colors.black)),
          subtitle: Text(device.address.toString(), style: const TextStyle(color: Colors.black38)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              device.isConnected
                  ? const Icon(Icons.import_export)
                  : const SizedBox(width: 0, height: 0),
              device.isBonded
                  ? const Icon(Icons.link)
                  : const SizedBox(width: 0, height: 0),
            ],
          ),
        );

}
enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;

  _DeviceWithAvailability(this.device, this.availability);
}
