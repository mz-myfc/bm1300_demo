import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/*
 * @description Bluetooth devices
 * @author zl
 * @date 2023/11/20 16:19
 */
class BleDevice {
  late DiscoveredDevice device;
  late int rssi;
  late bool isConnected;

  BleDevice(this.device, this.rssi, this.isConnected);
}
