import 'dart:async';

import 'package:flutter/material.dart';

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
    isSendCommand = false;
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

    if (spo2 < 35 || spo2 > 100) spo2 = 0;
    if (pr < 25 || pr > 250) pr = 0;
    if (pi < 1 || pi > 200) pi = 0;
    if (sys < 40 || sys > 230) sys = 0;
    if (dia < 40 || dia > 230) dia = 0;

    _setData(sys, dia, spo2, pr, pi / 10);
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

  void _setData(int sys, int dia, int spo2, int pr, double pi) {
    this.sys = sys;
    this.dia = dia;
    this.spo2 = spo2;
    this.pr = pr;
    this.pi = pi;
  }

  //Start the BM1300 refresh interface
  void startTimer() {
    stopTimer();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notify();
    });
  }

  //Stop the timer
  void stopTimer() {
    timer?.cancel();
    timer = null;
  }
}

extension Format on num {
  String get intVal => this > 0 ? '$this' : '--';
  String get asFixed => this >0 ? toStringAsFixed(1) : '--';
}
