import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble/ble_helper.dart';
import 'parse/cnibp_protocol_v1.3.dart';

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

  int sys = 0; //Systolic Blood Pressure
  int dia = 0; //Diastolic Blood Pressure
  int spo2 = 0; //Oxygen Saturation
  int pr = 0; //Pulse Rate
  double pi = 0.0; //Perfusion index

  int battery = 0;
  String deviceName = '--';
  String deviceId = '--';

  Timer? timer;

  //Simulate a user's blood pressure value. For the official version, please set it according to the actual user information.
  Map<String, dynamic> user = {'sys': 120, 'dia': 80};

  void init() {
    CNIBPProtocol.instance.init();
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
    refresh();
  }

  //Notification refresh
  void refresh() => notifyListeners();

  //Read the value
  void read(List<int> array) {
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
      refresh();
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
    refresh();
  }

  ///Get Mac, iOS compatible
  String _getMac(DiscoveredDevice device) {
    var manufacturerData = device.manufacturerData.toList();
    if (manufacturerData.length >= 8) {
      var mac = manufacturerData
          .sublist(2, 8)
          .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
          .toList();
      return mac.toParts;
    }
    return device.id.startsWith('00:A0:50') ? device.id : '--';
  }


  //Handles characters that are not recognized by Bluetooth names
  String _setBleName(String name) {
    if (name.codeUnits.contains(0)) {
      return String.fromCharCodes(
        Uint8List.fromList(name.codeUnits.sublist(0, name.codeUnits.indexOf(0))),
      );
    }
    return name;
  }
}

extension Format on num {
  String get intVal => this > 0 ? '$this' : '--';

  String get asFixed => this > 0 ? toStringAsFixed(1) : '--';

  double get toDou => this > 0 ? double.parse(toStringAsFixed(1)) : 0.0;

  String get battery => this > 0 ? '$this%' : '--';
}

extension MyListFormat on List {
  String get toParts =>
      isNotEmpty ? map((e) => e.toString().padLeft(2, '0')).join(':') : '';
}
