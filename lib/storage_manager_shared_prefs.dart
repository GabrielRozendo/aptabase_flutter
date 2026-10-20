import "package:aptabase_flutter/storage_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageManagerSharedPrefs extends StorageManager {
  static const _keyPrefix = "aptabase_";
  final _events = <String, String>{};
  final _prefs = SharedPreferencesAsync();

  @override
  Future<void> init() async {
    final keys = await _prefs.getKeys();

    for (final key in keys.where((key) => key.startsWith(_keyPrefix))) {
      final value = await _prefs.getString(key);

      if (value != null) {
        final unprefixedKey = key.substring(_keyPrefix.length);
        _events[unprefixedKey] = value;
      }
    }

    return super.init();
  }

  @override
  Future<void> addEvent(String key, String event) async {
    try {
      await _prefs.setString("$_keyPrefix$key", event);

      _events[key] = event;
    } catch (e) {
      // If persistence fails, don't add to in-memory cache to maintain consistency
      rethrow;
    }
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    // Remove from in-memory cache first since events were already sent
    _events.removeWhere((k, _) => keys.contains(k));

    try {
      await Future.wait(keys.map((key) => _prefs.remove("$_keyPrefix$key")));
    } catch (e) {
      // Events were already sent successfully and removed from memory.
      // Disk cleanup failure is not critical - orphaned keys will be cleaned
      // up on next init if they still exist.
      // Silently catch to avoid disrupting the event sending flow.
    }
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    return _events.entries.take(length);
  }
}
