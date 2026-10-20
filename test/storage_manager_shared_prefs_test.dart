import "package:aptabase_flutter/storage_manager_shared_prefs.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart";
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";

void main() {
  test("loads only Aptabase string events from shared preferences", () async {
    SharedPreferences.setMockInitialValues({
      "flutter.analytics_enabled": true,
      "aptabase_1": "event-one",
      "aptabase_2": 2,
    });
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final storage = StorageManagerSharedPrefs();
    await storage.init();

    final items = (await storage.getItems(10)).toList();

    expect(items, hasLength(1));
    expect(items.single.key, "aptabase_1");
    expect(items.single.value, "event-one");
  });
}
