import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '/native_bindings/andrid_utils.dart' show SDKInt;
class PermissionService {
  static Future<bool> getExtStoragePermission() async {
    if (GetPlatform.isDesktop) {
      return Future.value(true);
    }
    if ((SDKInt.Companion.getSDKInt()) < 30) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        await [
          Permission.storage,
          Permission.accessMediaLocation,
          Permission.mediaLibrary,
        ].request();
      }

      if (await Permission.storage.isPermanentlyDenied) {
        await openAppSettings();
      }

      return (await Permission.storage.status).isGranted;
    } else {
      if (!await Permission.manageExternalStorage.isGranted) {
        final permission = await Permission.manageExternalStorage.request();
        return permission.isGranted;
      }
      return true;
    }
  }
}
