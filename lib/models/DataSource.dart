import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mic_stream/mic_stream.dart';

import 'options/SensorOptions.dart';

abstract class DataSource {
  var _parser;

  setParser(parser){
    _parser = parser;
  }

  activate();
  deactivate();

  bool isActivate();

  void errorHandler(error, StackTrace trace){
    deactivate();
  }
  void doneHandler(){
    deactivate();
  }

}

class MicCapture extends DataSource {
  bool isActive = false;
  var _subscription;

  @override
  activate() async{
    var stream = await MicStream.microphone(
        audioSource: AudioSource.VOICE_RECOGNITION,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);

    isActive = true;
    _subscription = stream?.listen((samples){
      if(isActive) _parser.parse(samples);
    });
  }

  @override
  deactivate() {
    _subscription.cancel();
    isActive = false;
  }

  @override
  bool isActivate() {
    return isActive;
  }

}

class BlueDevice{
  final BluetoothDevice device;
  BlueDevice(this.device);
}

class BlueConnection extends DataSource {
  var name = " ";
  var address = " ";
  BluetoothConnection? blueConnection;
  bool isResetting = false;
  late SensorOptions sensorOptions;

  setSensorOptions(options){
    sensorOptions = options;
  }

  static discovery() async{
    var devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    var ret = <BlueDevice>[];
    for(var device in devices){ ret.add(BlueDevice(device));}
    return ret;
  }

  _tryToConnect() async{
    await BluetoothConnection.toAddress(address).then((_connection) {
      blueConnection = _connection;
      blueConnection?.input?.listen((data){
        _parser.parse(data);
      });
    }, onError:(e) async{
      await BluetoothConnection.toAddress(address).then((_connection) {
        blueConnection = _connection;
        blueConnection?.input?.listen((data){
          _parser.parse(data);
        });
      }, onError:(e){
        assert(false);
      }
      );
    });
  }

  @override
  activate() async{
    var index = _parser.startI;

    try {
      await _tryToConnect().then((_) {
            for(int i=1; i<4; i++){
              sensorOptions.map['di'+(index+i).toString()] = name;
            }
          BotToast.showText(text: name + " - Connected",
            duration: const Duration(seconds: 2),
            align: const Alignment(0, 0),);
      });
    } catch (e) {
      for(int i=1; i<4; i++){
        sensorOptions.map['di'+(index+i).toString()] = 'disconnected';
      }
      BotToast.showText(text: "찾을 수 없는 디바이스입니다.",
        duration: const Duration(seconds: 2),
        align: const Alignment(0, 0),);
    }
  }

  @override
  deactivate() {
    if(isActivate()) {
      blueConnection?.close();
      _parser.reset();

      var index = _parser.startI;
      for(int i=1; i<4; i++){
        sensorOptions.map['di'+(index+i).toString()] = 'disconnected';
      }
      BotToast.showText(text: name + " - Disconnected",
        duration: const Duration(seconds: 1),
        align: const Alignment(0, 0),);

      sensorOptions.save();
    }
  }

  @override
  bool isActivate() {
    if(blueConnection == null) return false;
    return blueConnection!.isConnected || isResetting;
  }

}

class TcpConnection extends DataSource {
  late final String _ipv4;
  late final int _port;
  Socket? _clientSocket;

  @override
  activate() {
    if(_clientSocket != null){
      deactivate();
      return;
    }

    Socket.connect(_ipv4, _port, timeout: const Duration(seconds: 5)).then((socket){
      _clientSocket = socket;
      socket.listen((data){
        _parser.parse(data);
      },
        onError: errorHandler,
        onDone: doneHandler,
        cancelOnError: false,
      );
    });
  }

  @override
  deactivate() {
    if(_clientSocket != null) {
      _clientSocket?.close();
      _clientSocket?.destroy();
      _clientSocket = null;
    }
    _parser.reset();
  }

  @override
  bool isActivate() {
    return _clientSocket != null;
  }

}