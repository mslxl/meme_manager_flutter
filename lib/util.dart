import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.manageExternalStorage
  ].request();
  return statuses.values.map((e) => e.isGranted).reduce((value, element) => value && element);
}