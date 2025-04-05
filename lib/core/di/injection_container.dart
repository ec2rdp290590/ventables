import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ventables/core/network/network_info.dart';
import 'package:ventables/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ventables/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ventables/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ventables/features/auth/domain/repositories/auth_repository.dart';
import 'package:ventables/features/auth/domain/usecases/get_current_user.dart';
import 'package:ventables/features/auth/domain/usecases/login_user.dart';
import 'package:ventables/features/auth/domain/usecases/logout_user.dart';
import 'package:ventables/features/auth/domain/usecases/register_user.dart';
import 'package:ventables/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ventables/features/products/data/datasources/products_remote_data_source.dart';
import 'package:ventables/features/products/data/repositories/products_repository_impl.dart';
import 'package:ventables/features/products/domain/repositories/products_repository.dart';
import 'package:ventables/features/products/domain/usecases/get_product_details.dart';
import 'package:ventables/features/products/domain/usecases/get_products.dart';
import 'package:ventables/features/products/presentation/bloc/products_bloc.dart';
import 'package:ventables/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:ventables/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ventables/features/cart/domain/repositories/cart_repository.dart';
import 'package:ventables/features/cart/domain/usecases/add_to_cart.dart';
import 'package:ventables/features/cart/domain/usecases/get_cart.dart';
import 'package:ventables/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:ventables/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ventables/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ventables/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ventables/features/profile/domain/repositories/profile_repository.dart';
import 'package:ventables/features/profile/domain/usecases/get_user_profile.dart';
import 'package:ventables/features/profile/domain/usecases/update_user_profile.dart';
import 'package:ventables/features/profile/presentation/bloc/profile_bloc.dart';

// Instancia global del contenedor de inyección de dependencias
final sl = GetIt.instance;

// Inicialización del contenedor de inyección de dependencias
Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      loginUser: sl(),
      logoutUser: sl(),
      registerUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Products
  // Bloc
  sl.registerFactory(
    () => ProductsBloc(
      getProducts: sl(),
      getProductDetails: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Cart
  // Bloc
  sl.registerFactory(
    () => CartBloc(
      getCart: sl(),
      addToCart: sl(),
      removeFromCart: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(()  => RemoveFromCart(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Profile
  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
