import 'package:shared_preferences/shared_preferences.dart';

//To store key:val data
storeStringToSF(String stringKey, String stringVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(stringKey, stringVal);
}

storeIntToSF(String intKey, int intVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(intKey, intVal);
}

storeDoubleToSF(String doubleKey, double doubleVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(doubleKey, doubleVal);
}

storeBoolToSF(String boolKey, bool boolVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(boolKey, boolVal);
}

//To fetch key:val data
Future<String> fetchStringValuesSF(String stringKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
//Return String
  return prefs.getString(stringKey) ?? "";
}

Future<int> fetchIntValuesSF(String intKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
//Return int
  return prefs.getInt(intKey) ?? 0;
}

Future<double> fetchDoubleValuesSF(String doubleKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
//Return double
  return prefs.getDouble(doubleKey) ?? 0;
}

Future<bool> fetchBoolValuesSF(String boolKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
//Return bool
  return prefs.getBool(boolKey) ?? false;
}

Future<void> clearValueFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Future<void> clearAllStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
