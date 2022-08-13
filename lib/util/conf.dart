import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static Config? _INSTANCE;

  static Future<Config> getInstance() async {
    if (_INSTANCE != null) return _INSTANCE!;

    Config cfg = Config();
    await withSharedPref((pref) async {
      cfg._storageFolder = pref.getString("storage_folder") ??
          join((await getApplicationDocumentsDirectory()).path, "meme");
      cfg._currentLang = pref.getInt("lang") ?? 2;
      cfg._homeRow = pref.getInt("row_home") ?? 2;
    });

    _INSTANCE = cfg;
    return cfg;
  }

  static Future<void> withSharedPref(Function(SharedPreferences) action) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await action(pref);
  }

  String? _storageFolder;
  int _currentLang = 0;

  int _homeRow = 2;

  int get homeRow {
    return _homeRow;
  }

  String get storageFolder {
    return _storageFolder!;
  }

  int get lang {
    return _currentLang;
  }

  void setStorageFolder(String folder) async {
    _storageFolder = folder;
    await withSharedPref((pref) {
      pref.setString("storage_folder", _storageFolder!);
    });
  }

  void setLang(int i) async {
    _currentLang = i;
    await withSharedPref((pref) {
      pref.setInt("lang", _currentLang);
    });
  }
  void setHomeRow(int i) async {
    _homeRow = i;
    await withSharedPref((pref) {
      pref.setInt("row_home", _currentLang);
    });
  }
}
