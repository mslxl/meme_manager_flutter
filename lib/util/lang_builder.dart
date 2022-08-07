import 'package:mmm/messages/mlang.i18n.dart';
import 'package:mmm/messages/mlang_eo.i18n.dart';
import 'package:mmm/messages/mlang_zh.i18n.dart';

class LangBuilder {
  static final List<Mlang> _lang =
      List.of(const [Mlang(), MlangEo(), MlangZh()]);
  static int _usingLang = 0;

  static void setLang(int i) {
    _usingLang = i;
  }

  static Mlang get currentLang {
    return _lang[_usingLang];
  }
}
