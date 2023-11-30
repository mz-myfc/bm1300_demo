import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sprintf/sprintf.dart';

import 'ble_helper.dart';

/*
 * @description Helper
 * @author zl
 * @date 2023/11/20 16:15
 */
class Helper extends ChangeNotifier {
  static final Helper h = Helper._();

  Helper._();

  bool isSendCommand = false;
  List<int> sbpArray = [];
  List<int> dbpArray = [];

  List<int> bufferArray = [];
  int sys = 0;
  int dia = 0;
  int spo2 = 0;
  int pr = 0;
  double pi = 0.0;
  int battery = 0;
  String deviceName = '--';
  String deviceId = '--';

  Timer? timer;

  //Simulate a user's blood pressure value. For the official version, please set it according to the actual user information.
  Map<String, dynamic> user = {
    'sys': 120,
    'dia': 80,
  };

  void init() {
    bufferArray = [];
    sbpArray = [];
    dbpArray = [];
    sys = 0;
    dia = 0;
    spo2 = 0;
    pr = 0;
    pi = 0.0;
    battery = 0;
    deviceName = '--';
    deviceId = '--';
    isSendCommand = false;
    notify();
  }

  //Bluetooth data analysis
  void analysis(List<int> array) {
    bufferArray += array;
    var i = 0; //Current index
    var validIndex = 0; //Valid indexes
    var maxIndex = bufferArray.length - 20; //Leave at least enough room for a minimum set of data
    while (i <= maxIndex) {
      //Failed to match the headers
      if (bufferArray[i] != 0xFF || bufferArray[i + 1] != 0xAA) {
        i += 1;
        validIndex = i;
        continue;
      }
      //The header is successfully matched
      var total = 0;
      var checkSum = bufferArray[i + 19];
      for (var index = 0; index <= 18; index++) {
        total += bufferArray[i + index];
      }
      //If the verification fails, discard the two data
      if (checkSum != total % 256) {
        i += 2;
        validIndex = i;
        continue;
      }
      _read(bufferArray.sublist(i, i + 19));
      i += 20; //Move back one group
      validIndex = i;
      continue;
    }
    bufferArray = bufferArray.sublist(validIndex); //Reorganize the cache array, delete all the data before the valid index
  }

  //Notification refresh
  void notify() => notifyListeners();

  //Read the value
  void _read(List<int> array) {
    var spo2 = array[4];
    var pr = array[5];
    var pi = array[6];
    var sys = array[7];
    var dia = array[8];
    var battery = array[12];

    if (spo2 < 35 || spo2 > 100) spo2 = 0;
    if (pr < 25 || pr > 250) pr = 0;
    if (pi < 1 || pi > 200) pi = 0;
    if (sys < 40 || sys > 230) sys = 0;
    if (dia < 40 || dia > 230) dia = 0;

    _setData(sys, dia, spo2, pr, pi / 10, battery);
    _calibrate(sys, dia);
  }

  //Calibrate blood pressure
  void _calibrate(int sbp, int dbp) {
    if (!isSendCommand && sbp != 0 && dbp != 0) {
      sbpArray.add(sbp);
      dbpArray.add(dbp);
      if (sbpArray.length > 1000) {
        //Send a write command to calibrate your blood pressure
        isSendCommand = true;
        if ((user['sys'] >= 40 && user['sys'] <= 230) && (user['dia'] >= 40 && user['dia'] <= 230)) {
          Ble.helper.calibrate(user['sys'], user['dia']); // Blood pressure calibration
        }
        sbpArray = [];
        dbpArray = [];
      }
    }
  }

  void _setData(int sys, int dia, int spo2, int pr, double pi, int battery) {
    this.sys = sys;
    this.dia = dia;
    this.spo2 = spo2;
    this.pr = pr;
    this.pi = pi;
    this.battery = battery;
  }

  //Start the BM1300 refresh interface
  void startTimer() {
    stopTimer();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notify();
    });
  }

  //Stop the timer
  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void setDeviceInfo(DiscoveredDevice device){
    deviceName = _setBleName(device.name);
    deviceId = _getMac(device);
    notify();
  }

  ///Get Mac, iOS compatible
  String _getMac(DiscoveredDevice device) {
    var manufacturerData = device.manufacturerData.toList();
    if (manufacturerData.length >= 8) {
      var mac = manufacturerData
          .sublist(2, 8)
          .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
          .toList();
      return sprintf('%s:%s:%s:%s:%s:%s', mac).toString();
    }
    return device.id.startsWith('00:A0:50') ? device.id : '--';
  }


  //Handles characters that are not recognized by Bluetooth names
  String _setBleName(String name) {
    try {
      if (name.codeUnits.contains(0)) {
        return String.fromCharCodes(Uint8List.fromList(
            name.codeUnits.sublist(0, name.codeUnits.indexOf(0))));
      } else {
        return name;
      }
    } catch (_) {}
    return '--';
  }
}

extension Format on num {
  String get intVal => this > 0 ? '$this' : '--';
  String get asFixed => this > 0 ? toStringAsFixed(1) : '--';
  double get toDou1 => this > 0 ? double.parse(toStringAsFixed(1)) :  0.0;
  String get batt => this > 0 ? '$this%' : '--';
}
