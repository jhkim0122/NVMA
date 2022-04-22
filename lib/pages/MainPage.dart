
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/DataDestination.dart';
import '../models/DataModel.dart';
import '../models/DataSource.dart';
import '../models/Parser.dart';
import '../models/Processor.dart';
import '../models/options/BluetoothOptions.dart';
import '../models/options/SensorOptions.dart';
import '../utils/NVMABottomNavigationBar.dart';
import 'NoiseMeasurementPage.dart';
import 'SettingPage.dart';
import 'VibrationMeasurementPage.dart';

class MainPage extends StatefulWidget{
  const MainPage({key}) : super(key:key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final int _mainIndex = 0;
  final int _noiseIndex = 1;
  final int _vibIndex = 2;
  final int _settingIndex = 3;
  late int selectedIndex;

  var sensorTimeDataModelsMap = Map<String, RealtimeSensorTimeDataModel>();
  late MicCapture _micCapture;
  late TcpConnection _tcpConnection;
  final List<BlueConnection> _btConnectionList = [];

  var sensorOptions = SensorOptions();
  var bluetoothOptions = BluetoothOptions();

  var _pageViewList = [];
  final PageController _pageController = PageController(initialPage: 0);

  @override
  initState() {
    super.initState();
    selectedIndex = _mainIndex;

    _micCapture = MicCapture();
    RealtimeSensorTimeDataModel micTimeDataModel = RealtimeSensorTimeDataModel(4096, 4000);
    micTimeDataModel.setOriginalDataSamplingRate(48000.0);
    sensorTimeDataModelsMap["internal mic"] = micTimeDataModel;
    var _micParser = InternalMicParser(sensorTimeDataModelsMap);
    var _micProcessor = ConvertToByteDataProcessor()..setDestination(Logger(appName));
    _micParser.setProcessor(_micProcessor);
    _micCapture.setParser(InternalMicParser(sensorTimeDataModelsMap));

    _tcpConnection = TcpConnection();
    var _tcpParser = NVDSDataParser(sensorTimeDataModelsMap);
    var _tcpProcessor = ConvertToByteDataProcessor()..setDestination(Logger(appName));
    _tcpParser.setProcessor(_tcpProcessor);
    _tcpConnection.setParser(_tcpParser);

    sensorOptions.load();
    _getBluetoothConnections();

    _pageViewList = [for(int i=0; i<=_settingIndex; i++)_getBody(i)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text(_getAppBarText(selectedIndex), style: const TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
        elevation:3.0,
      ),
      body: PageView.builder(
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) => _pageViewList[index],
          onPageChanged: (index) {
            selectedIndex = index;
            setState((){});
          },
          itemCount: _pageViewList.length,
      ),
      bottomNavigationBar: NVMABottomNavigationBar(_setPageIndex, selectedIndex),
    );
  }

  String _getAppBarText(index){
    if(index == _mainIndex){return "Noise Vibration Measurement App";}
    else if(index == _noiseIndex){return "Noise Measurement Page";}
    else if(index == _vibIndex) {return "Vibration Measurement Page";}
    else if(index == _settingIndex) {return "Setting Page";}
    else {return "";}
  }

  Widget _getBody(index){
    if(index == _mainIndex){
      return SingleChildScrollView(
          padding: const EdgeInsets.only(top:10, left:15, right:15),
          child: Column(
              children:[
                ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(left:12, top:5),
                        child: Icon(Icons.mic, color: Colors.black)
                    ),
                    title: const Text('Noise Measurement', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                    subtitle: const Padding(padding:EdgeInsets.only(left:5, top:10), child:Text('내장마이크로 소음 측정', style:TextStyle(color:Colors.grey))),
                    trailing: const Icon(Icons.navigate_next),
                    contentPadding: const EdgeInsets.symmetric(vertical:10),
                    onTap: () => setState((){
                      selectedIndex = _noiseIndex;
                      _setPageIndex(selectedIndex);
                    })
                ),
                const Divider(height:2.0, color: Colors.black45),
                ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(left:12, top:5),
                        child:Icon(Icons.vibration, color: Colors.black)
                    ),
                    title: const Text('Vibration Measurement', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                    subtitle: const Padding(padding:EdgeInsets.only(left:5, top:10), child:Text('무선 센서로 진동 측정', style:TextStyle(color:Colors.grey))),
                    trailing: const Icon(Icons.navigate_next),
                    contentPadding: const EdgeInsets.symmetric(vertical:10),
                    onTap: () => setState((){
                      selectedIndex = _vibIndex;
                      _setPageIndex(selectedIndex);
                    })
                ),
                const Divider(height:2.0, color: Colors.black45),
                ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(left:12, top:5),
                        child:Icon(Icons.settings, color: Colors.black)
                    ),
                    title: const Text('Settings', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                    subtitle: const Padding(padding:EdgeInsets.only(left:5, top:10), child:Text('설정', style:TextStyle(color:Colors.grey))),
                    trailing: const Icon(Icons.navigate_next),
                    contentPadding: const EdgeInsets.symmetric(vertical:10),
                    onTap: () => setState((){
                      selectedIndex = _settingIndex;
                      _setPageIndex(selectedIndex);
                    })
                ),
                const Divider(height:2.0, color: Colors.black45),
              ])
      );
    } else if(index == _noiseIndex){
      return NoiseMeasurementPage(_micCapture, sensorTimeDataModelsMap);
    } else if(index == _vibIndex) {
      return VibrationMeasurementPage(_btConnectionList, _tcpConnection, sensorTimeDataModelsMap);
    } else if(index == _settingIndex) {
      return SettingPage(_micCapture, _btConnectionList, _tcpConnection, sensorTimeDataModelsMap, bluetoothOptions, sensorOptions);
    } else {
      assert(false);
      return const SizedBox();
    }
  }

  _setPageIndex(index){
    selectedIndex = index;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
    setState((){});
  }

  void _getBluetoothConnections() {
    bluetoothOptions.load().then((_){
      if (bluetoothOptions.map.isNotEmpty) {
        bluetoothOptions.map.forEach((k, v) {
          BlueConnection _btConnection = BlueConnection();
          _btConnection.name = v;
          _btConnection.address = k;
          _btConnection.setSensorOptions(sensorOptions);
          var _btParser = Esp32AdxlParser(0, sensorTimeDataModelsMap);
          var _btProcessor = ConvertToByteDataProcessor()..setDestination(Logger(appName));
          _btParser.setProcessor(_btProcessor);
          _btConnection.setParser(_btParser);
          for (int i = 1; i < 4; i++) {
            if (!sensorOptions.map.containsKey('di' + ((_btConnectionList.length * 3) + i).toString() + "_type")) {
              sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString() + "_type"] = "Vibration";
              sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString() + "_sensitivity"] = 26122.0;
              if (i == 1) sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString() + "_position"] = "X";
              else if (i == 2) sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString() + "_position"] = "Y";
              else if (i == 3) sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString() + "_position"] = "Z";
            }
            sensorOptions.map['di' + ((_btConnectionList.length * 3) + i).toString()] = 'disconnected';
            sensorTimeDataModelsMap['di' + ((_btConnectionList.length * 3) + i).toString()] = RealtimeSensorTimeDataModel(4096, 2000);
            sensorTimeDataModelsMap['di' + ((_btConnectionList.length * 3) + i).toString()]?.setOriginalDataSamplingRate(4000.0);
          }
          sensorOptions.save();
          _btConnectionList.add(_btConnection);
        });
      }
      setState((){});
    });
  }
}