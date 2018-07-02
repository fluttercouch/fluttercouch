import 'select_result_as.dart';
import 'select_result_from.dart';

class SelectResult {
  static SelectResult_From all() {
    return SelectResult_From()..selectResultFromAll = "true";
  }

  static SelectResult_As property(String property) {
    return SelectResult_As()..content = property;
  }
}