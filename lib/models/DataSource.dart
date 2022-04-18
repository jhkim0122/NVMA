import 'dart:io';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mic_stream/mic_stream.dart';

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

  @override
  activate() async{
    var stream = await MicStream.microphone(
        audioSource: AudioSource.VOICE_RECOGNITION,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);

    stream?.listen((samples){
      if(samples == null) isActive = false;
      else isActive = true;
      _parser.parse(samples);
    });
  }

  @override
  deactivate() {
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

  static discovery() async{
    var devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    var ret = <BlueDevice>[];
    for(var device in devices){ ret.add(BlueDevice(device));}
    return ret;
  }

  @override
  activate() async{
    if(isActivate()){
      deactivate();
      return;
    }

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
  deactivate() {
    blueConnection?.close();
    _parser.resetLogger();
    _parser.reset();
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
    _parser.resetLogger();
    _parser.reset();
  }

  @override
  bool isActivate() {
    return _clientSocket != null;
  }

}