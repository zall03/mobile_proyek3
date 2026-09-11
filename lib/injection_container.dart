import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/dio_client.dart';

final sl = GetIt.instance; // service locator

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => DioClient(sl()));

  // Fitur-fitur akan didaftarkan di sini secara bertahap
  // (auth, stock, recipe) saat masing-masing kita bangun
}
