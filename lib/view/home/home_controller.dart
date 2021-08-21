
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_apps/device_apps.dart';

class HomeController extends GetxController {
  static const _platform = MethodChannel("mememan/share");
  var appTim = RxBool(false);
  var appQQ = RxBool(false);
  var appWechat = RxBool(false);
  var appIcons = Map();

  shareMeme(MemeModel model) {
    Share.shareFiles([model.path], mimeTypes: ["image/*"]);
  }

  @override
  void onInit() {
    super.onInit();
    _queryAppSupport();
  }

  shareMemeTo(MemeModel meme,String target) async {
    await _platform.invokeMethod("shareTo",{
      "target": target,
      "path":meme.path
    });
  }

  _queryAppSupport() async {
    var detectApp = (String pkgName, void Function(String) block) async {
      if (await DeviceApps.isAppInstalled(pkgName)) {
        block(pkgName);
      }
    };
    detectApp("com.tencent.tim", (p) async {
      appTim.value = true;
      var app = (await DeviceApps.getApp(p, true)) as ApplicationWithIcon;
      appIcons["tim"] = app.icon;
    });
    detectApp("com.tencent.mm", (p) async {
      appWechat.value = true;
      var app = (await DeviceApps.getApp(p, true)) as ApplicationWithIcon;
      appIcons["wechat"] = app.icon;
    });
    detectApp("com.tencent.mobileqq", (p) async {
      appQQ.value = true;
      var app = (await DeviceApps.getApp(p, true)) as ApplicationWithIcon;
      appIcons["qq"] = app.icon;
    });
  }
}
