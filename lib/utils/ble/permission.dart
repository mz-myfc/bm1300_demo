import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pop/pop.dart';
import 'ble_helper.dart';

/*
 * @description 权限管理
 * @author zl
 * @date 2024/9/24 10:51
 */
class PermissionHelper {
  static final PermissionHelper helper = PermissionHelper._();

  PermissionHelper._();

  /*
   * 蓝牙搜索需要权限
   */
  void scanBluetooth() async {
    BleStatus bleStatus = Ble.helper.bleStatus;
    if (Platform.isIOS) {
      await Permission.bluetooth.request();
      if (bleStatus == BleStatus.ready) {
        await Ble.helper.startScan();
      }
    } else {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();
      switch (bleStatus) {
        case BleStatus.ready: //蓝牙已就绪
          await Ble.helper.startScan();
          break;
        case BleStatus.unauthorized: //未授权(APP位置信息)
          _openPermission(type: 'app_location');
          break;
        case BleStatus.locationServicesDisabled: //位置服务已禁用(GPS/定位)
          _openPermission(type: 'location');
          break;
        case BleStatus.poweredOff: //蓝牙已关闭
          _openPermission(type: 'bluetooth');
          break;
        case BleStatus.unsupported:
        case BleStatus.unknown:
          Pop.helper.toast(msg: 'Check Bluetooth');
          break;
      }
    }
  }

  ///请求打开权限
  void _openPermission({required String type}) {
    switch (type) {
      case 'app_location':
        Permission.location.request().then((value) {
          if (value.isDenied || value.isPermanentlyDenied) {
            Pop.helper.dismiss();
            openAppSettings();
          } else {
            Ble.helper.startScan();
          }
        });
        break;
      case 'location':
        Pop.helper.dismiss();
        openLocation();
        break;
      case 'bluetooth':
        Pop.helper.dismiss();
        openBluetooth();
        break;
    }
  }

  void openWifi() =>
      AppSettings.openAppSettings(type: AppSettingsType.wifi); //打开WiFi

  void openLocation() =>
      AppSettings.openAppSettings(type: AppSettingsType.location); //打开定位

  void openAppSettings() => AppSettings.openAppSettings(); //打开APP设置

  void openNotification() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification); //打开通知

  void openBluetooth() =>
      AppSettings.openAppSettings(type: AppSettingsType.bluetooth); //打开蓝牙

  void openDataRoaming() =>
      AppSettings.openAppSettings(type: AppSettingsType.dataRoaming); //打开数据网络
}
