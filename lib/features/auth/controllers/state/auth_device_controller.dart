// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:petroject/features/user/domain/user_model.dart';
// import 'package:universal_platform/universal_platform.dart';

// class AuthDeviceController {
//   Future<Device?> fetchDeviceInfo() async {
//     DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

//     try {
//       // if (Theme.of(context).platform == TargetPlatform.windows)
//       if (UniversalPlatform.isDesktop) {
//         WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;

//         return Device(
//             deviceId: windowsInfo.deviceId,
//             name: windowsInfo.computerName,
//             os: "Windows 11",
//             fcmToken: "testToken");

//         // } else if (Theme.of(context).platform == TargetPlatform.macOS) {
//         //   MacOsDeviceInfo macInfo = await deviceInfoPlugin.macOsInfo;
//         //   info = 'MacOS Device:\n'
//         //       'Model: ${macInfo.model}\n'
//         //       'OS Version: ${macInfo.osRelease}';
//         // }
//       }
//       // use else if for other OS or platforms as well

//       // could not get device id
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }
// }
