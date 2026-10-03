import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  static const _key = 'crypto_watchlist_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
