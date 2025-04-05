import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ventables/config/app_router.dart';
import 'package:ventables/config/theme.dart';
import 'package:ventables/core/di/injection_container.dart' as di;
import 'package:ventables/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ventables/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ventables/features/products/presentation/bloc/products_bloc.dart';
import 'package:ventables/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ventables/features/splash/presentation/pages/splash_page.dart';

// Punto de entrada principal de la aplicación VenTables
void main() async {
  // Aseguramos que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos el contenedor de inyección de dependencias
  await di.init();
  
  // Ejecutamos la aplicación
  runApp(MyApp());
}

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Proporcionamos los BLoCs necesarios para la gestión de estado
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ProductsBloc>()),
        BlocProvider(create: (_) => di.sl<CartBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: MaterialApp(
        title: 'VenTables',
        debugShowCheckedModeBanner: false,
        // Aplicamos el tema personalizado
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // Configuramos las localizaciones para soporte multiidioma
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', ''),
          const Locale('en', ''),
        ],
        // Configuramos el enrutador para la navegación
        onGenerateRoute: AppRouter.onGenerateRoute,
        // Iniciamos con la página de splash
        home: SplashPage(),
      ),
    );
  }
}
