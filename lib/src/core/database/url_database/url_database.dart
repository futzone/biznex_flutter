import 'package:biznex/src/core/database/app_database/app_database.dart';

class UrlDatabase extends AppDatabase {
  Future<Box> _box() async {
    return await openBox('local_server_url');
  }

  @override
  Future delete({required String key}) async {
    final box = await _box();
    await box.clear();
  }

  @override
  Future get() async {
    final box = await _box();
    return box.get('url'); 
  }

  @override
  Future<void> set({required data}) async {
    final box = await _box();
    await box.put('url', data);
  }

  @override
  Future<void> update({required String key, required data}) async {
    final box = await _box();
    box.put('url', data);
  }
}
