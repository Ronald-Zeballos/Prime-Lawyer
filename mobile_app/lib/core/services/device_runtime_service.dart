import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

enum DeviceRuntimeKind {
  physical,
  virtual,
  unsupported,
}

class DeviceRuntimeService {
  DeviceRuntimeService({
    DeviceInfoPlugin? deviceInfoPlugin,
  }) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfoPlugin;

  Future<DeviceRuntimeKind> getCurrentDeviceKind() async {
    if (kIsWeb) {
      return DeviceRuntimeKind.unsupported;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;

        return androidInfo.isPhysicalDevice
            ? DeviceRuntimeKind.physical
            : DeviceRuntimeKind.virtual;
      }

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;

        return iosInfo.isPhysicalDevice
            ? DeviceRuntimeKind.physical
            : DeviceRuntimeKind.virtual;
      }
    } catch (_) {
      return DeviceRuntimeKind.unsupported;
    }

    return DeviceRuntimeKind.unsupported;
  }
}
