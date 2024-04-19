import 'dart:async';
import 'dart:io';

import 'package:bm1300_demo/utils/helper.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble_device.dart';
import 'cmd.dart';
import 'pop/pop.dart';

/*
 * @description Bluetooth
 * @author zl
 * @date 2023/11/20 15:05
 */
class Ble {
  static final Ble helper = Ble._();

  Ble._();

  final ble = FlutterReactiveBle();

  Timer? timer;
  List<BleDevice> tempDeviceArray = []; // A list of devices
  DiscoveredDevice? currentDevice; // Currently connected devices

  StreamSubscription<DiscoveredDevice>? scanSubscription; // Holds a scanning function
  StreamSubscription<ConnectionStateUpdate>? connectSubscription; // Hold the connection function

  BleStatus bleStatus = BleStatus.unknown;
}

extension BluetoothExtension on Ble {
  //Scan for Bluetooth devices
  Future<void> startScan() async {
    Pop.helper.loadAnimation(msg: 'Searching...');
    _startTimer(); // Turn on the timer
    await scanSubscription?.cancel();
    scanSubscription = ble.scanForDevices(withServices: []).listen((device) {
      if (device.name.isEmpty) return;
      var index = tempDeviceArray.indexWhere((e) => e.device.id == device.id);
      if (index >= 0) {
        tempDeviceArray[index] = BleDevice(device, device.rssi, false);
      } else {
        tempDeviceArray.add(BleDevice(device, device.rssi, false));
      }
    }, onError: (_) => _disconnect());
  }

  // Connect the device
  Future<void> _connect(DiscoveredDevice device) async {
    await _disconnect();
    connectSubscription = ble
        .connectToDevice(
            id: device.id,
            servicesWithCharacteristicsToDiscover: {
              Cmd.SERVICE_UUID: [
                Cmd.CHARACTERISTIC_UUID_SEND,
                Cmd.CHARACTERISTIC_UUID_RECEIVE
              ]
            },
            connectionTimeout: const Duration(seconds: 2))
        .listen(
          (connectionState) => _listener(connectionState, device),
          onError: (_) => _disconnect(),
        );
  }

  //Bluetooth status
  void _listener(ConnectionStateUpdate connectionState, DiscoveredDevice device) {
    switch (connectionState.connectionState) {
      case DeviceConnectionState.connecting:
        Pop.helper.loadAnimation(msg: 'Connecting...');
        break;
      case DeviceConnectionState.connected:
        Helper.h.setDeviceInfo(device);
        Pop.helper.dismiss();
        _readAndWrite(device);
        break;
      case DeviceConnectionState.disconnecting:
        break;
      case DeviceConnectionState.disconnected:
        _disconnect();
        Pop.helper.dismiss();
        Pop.helper.toast(msg: 'Bluetooth is disconnected');
        Helper.h.init();
        break;
    }
  }

  //Clear the list of devices
  void _clean() async {
    tempDeviceArray = [];
    try {
      if (Platform.isAndroid && currentDevice != null) {
        await ble.clearGattCache(currentDevice!.id);
      }
    } catch (_) {}
    currentDevice = null;
  }

  // Turn on the timer
  Future<void> _startTimer() async {
    _clean();
    await _stopTimer();
    timer = Timer.periodic(
        const Duration(seconds: 3), (_) async => await syncDevices());
  }

  // Stop the timer
  Future<void> _stopTimer() async {
    await scanSubscription?.cancel();
    scanSubscription = null;
    timer?.cancel();
    timer = null;
  }

  //A list of devices
  Future<void> syncDevices() async {
    var deviceArray = tempDeviceArray;
    deviceArray.sort((a, b) => b.rssi - a.rssi); //sort
    _stopTimer();
    if (deviceArray.isNotEmpty) {
      currentDevice = deviceArray.first.device;
      _connect(currentDevice!);
    } else {
      Pop.helper.toast(msg: 'There is no device available, please search again');
    }
  }

  // Stop scanning
  Future<void> _stopScan() async {
    await _stopTimer();
    await scanSubscription?.cancel();
    scanSubscription = null;
  }

  // Disconnect
  Future<void> _disconnect() async {
    await _stopScan();
    try {
      if (Platform.isAndroid && currentDevice != null) {
        await ble.clearGattCache(currentDevice!.id);
      }
    } catch (_) {}

    await connectSubscription?.cancel();
    connectSubscription = null;

    currentDevice = null;
    Pop.helper.dismiss();
  }

  Future<void> bleState() async {
    final ble = FlutterReactiveBle();
    // Listen for Bluetooth status
    ble.statusStream.listen((bleStatus) => this.bleStatus = bleStatus);

    // Listen to the device connection status
    ble.connectedDeviceStream.listen((event) async {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          break;
        case DeviceConnectionState.disconnected:
          await _disconnect();
          Pop.helper.dismiss();
          Helper.h.init();
          break;
        case DeviceConnectionState.connecting:
          break;
        case DeviceConnectionState.disconnecting:
          break;
      }
    }); 
  }

  void _readAndWrite(DiscoveredDevice device) {
    final characteristic = QualifiedCharacteristic(
      serviceId: Cmd.SERVICE_UUID,
      characteristicId: Cmd.CHARACTERISTIC_UUID_SEND,
      deviceId: device.id,
    );
    ble
        .subscribeToCharacteristic(characteristic)
        .listen((data) => _analysis(data), onError: (_) => _disconnect());
  }

  //Read and parse data
  void _analysis(List<int> data) => Helper.h.analysis(data);

  //Blood pressure calibration
  List<int> calibrate(int sys, int dia) => [0xFA, sys, 0xF9, dia];
}
