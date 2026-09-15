import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/resend_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_register_otp_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => DioClient(sl()));

  // Auth feature
  sl.registerLazySingleton(() => AuthRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => VerifyRegisterOtpUsecase(sl()));
  sl.registerLazySingleton(() => ResendOtpUsecase(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUsecase: sl(),
      registerUsecase: sl(),
      verifyOtpUsecase: sl(),
      resendOtpUsecase: sl(),
    ),
  );
}