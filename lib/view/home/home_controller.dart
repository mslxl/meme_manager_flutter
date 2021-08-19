import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:get/get.dart';
import 'package:meme_man/model/MemeModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_apps/device_apps.dart';

class HomeController extends GetxController {
  var appTim = RxBool(false);
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

  sendToTim(MemeModel meme) {
    var intent = AndroidIntent(
      action: "android.intent.action.SEND",
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      type: "image/*",
      componentName: "com.tencent.mobileqq.activity.JumpActivity",
      arguments:{
        "android.intent.extra.STREAM": File(meme.path).uri.toString()
      }
    );
    intent.launch();
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
  }
}
