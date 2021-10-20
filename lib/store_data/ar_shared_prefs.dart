import 'package:shared_preferences/shared_preferences.dart';

class ArSharedPrefs {
  static late SharedPreferences prefs;

  static void setLength(List<String> length) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setStringList('length', length);
  }
  static void setWidth(List<String> width) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setStringList('width', width);
  }
  static void setHeight(List<String> height) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setStringList('height', height);
  }

  static Future<List<String>?> getDimension(String dimension) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(dimension);
  }

  static void setFileDownloaded() async{
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('fileDownload', true);
  }
  static Future<bool> getFileDownloaded() async{
    prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fileDownload')??false;
  }
}