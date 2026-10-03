import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const key = 'crypto_device_id';

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'android-${DateTime.now().microsecondsSinceEpoch}';
    await prefs.setString(key, id);
    return id;
  }
}
