import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/dio_client.dart';
import 'core/services/google_auth_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/get_me_usecase.dart';
import 'features/auth/domain/usecases/update_me_usecase.dart';
import 'features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/resend_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_register_otp_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/stock/data/datasources/stock_remote_datasource.dart';
import 'features/stock/data/repositories/stock_repository_impl.dart';
import 'features/stock/domain/repositories/stock_repository.dart';
import 'features/stock/domain/usecases/add_stock_usecase.dart';
import 'features/stock/domain/usecases/delete_stock_usecase.dart';
import 'features/stock/domain/usecases/get_categories_usecase.dart';
import 'features/stock/domain/usecases/get_ingredients_usecase.dart';
import 'features/stock/domain/usecases/get_stocks_usecase.dart';
import 'features/stock/domain/usecases/update_stock_usecase.dart';
import 'features/stock/presentation/cubit/stock_cubit.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_dashboard_summary_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/recipe/data/datasources/recipe_remote_datasource.dart';
import 'features/recipe/data/repositories/recipe_repository_impl.dart';
import 'features/recipe/domain/repositories/recipe_repository.dart';
import 'features/recipe/domain/usecases/recipe_usecases.dart';
import 'features/recipe/presentation/cubit/recipe_cubit.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/cooking_log/data/datasources/cooking_log_remote_datasource.dart';
import 'features/cooking_log/data/repositories/cooking_log_repository_impl.dart';
import 'features/cooking_log/domain/repositories/cooking_log_repository.dart';
import 'features/cooking_log/domain/usecases/log_cooking_usecase.dart';
import 'features/cooking_log/presentation/cubit/cooking_log_cubit.dart';
import 'features/child/data/datasources/child_remote_datasource.dart';
import 'features/child/data/repositories/child_repository_impl.dart';
import 'features/child/domain/repositories/child_repository.dart';
import 'features/child/domain/usecases/child_usecases.dart';
import 'features/child/presentation/cubit/child_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => GoogleAuthService());

  // Auth feature
  sl.registerLazySingleton(() => AuthRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => VerifyRegisterOtpUsecase(sl()));
  sl.registerLazySingleton(() => ResendOtpUsecase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUsecase(sl()));
  sl.registerLazySingleton(() => GetMeUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMeUsecase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUsecase(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUsecase: sl(),
      registerUsecase: sl(),
      verifyOtpUsecase: sl(),
      resendOtpUsecase: sl(),
      googleSignInUsecase: sl(),
    ),
  );

  // Stock feature
  sl.registerLazySingleton(() => StockRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<StockRepository>(() => StockRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetIngredientsUsecase(sl()));
  sl.registerLazySingleton(() => GetStocksUsecase(sl()));
  sl.registerLazySingleton(() => AddStockUsecase(sl()));
  sl.registerLazySingleton(() => UpdateStockUsecase(sl()));
  sl.registerLazySingleton(() => DeleteStockUsecase(sl()));
  sl.registerFactory(
    () => StockCubit(
      getCategoriesUsecase: sl(),
      getIngredientsUsecase: sl(),
      getStocksUsecase: sl(),
      addStockUsecase: sl(),
      updateStockUsecase: sl(),
      deleteStockUsecase: sl(),
    ),
  );

  // Home dashboard feature
  sl.registerLazySingleton(() => HomeRemoteDatasource(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetDashboardSummaryUsecase(sl()));
  sl.registerFactory(
    () => HomeCubit(
      getDashboardSummaryUsecase: sl(),
      getChildrenUsecase: sl(),
    ),
  );

  // Recipe feature
  sl.registerLazySingleton(() => RecipeRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetRecipesUsecase(sl()));
  sl.registerLazySingleton(() => GetRecipeByIdUsecase(sl()));
  sl.registerLazySingleton(() => GenerateRecipeUsecase(sl()));
  sl.registerFactory(
    () => RecipeCubit(
      getRecipesUsecase: sl(),
      getRecipeByIdUsecase: sl(),
      generateRecipeUsecase: sl(),
    ),
  );

  // Notifications feature
  sl.registerLazySingleton(
    () => NotificationRemoteDatasource(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUsecase(sl()));
  sl.registerFactory(() => NotificationsCubit(getNotificationsUsecase: sl()));

  // Cooking Log feature
  sl.registerLazySingleton(() => CookingLogRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<CookingLogRepository>(
    () => CookingLogRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LogCookingUsecase(sl()));
  sl.registerFactory(() => CookingLogCubit(logCookingUsecase: sl()));

  // Child feature
  sl.registerLazySingleton(() => ChildRemoteDatasource(sl<DioClient>().dio));
  sl.registerLazySingleton<ChildRepository>(() => ChildRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetChildrenUsecase(sl()));
  sl.registerLazySingleton(() => GetChildByIdUsecase(sl()));
  sl.registerLazySingleton(() => CreateChildUsecase(sl()));
  sl.registerLazySingleton(() => UpdateChildUsecase(sl()));
  sl.registerLazySingleton(() => DeleteChildUsecase(sl()));
  sl.registerLazySingleton(() => GetMeasurementsUsecase(sl()));
  sl.registerLazySingleton(() => AddMeasurementUsecase(sl()));
  sl.registerFactory(
    () => ChildCubit(
      getChildrenUsecase: sl(),
      getChildByIdUsecase: sl(),
      createChildUsecase: sl(),
      updateChildUsecase: sl(),
      deleteChildUsecase: sl(),
    ),
  );
}
