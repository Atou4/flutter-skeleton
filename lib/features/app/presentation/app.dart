import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_skeleton/features/shared/language/presentation/cubit/language_cubit.dart';
import 'package:flutter_skeleton/l10n/l10n.dart';
import 'package:flutter_skeleton/navigation/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    context.findAncestorStateOfType<_AppState>();
    BlocProvider.of<LanguageCubit>(context)
        .changeLanguage(newLocale.languageCode);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => diContainer<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => diContainer<LanguageCubit>()..getCurrentLanguage(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  Future.delayed(const Duration(seconds: 1), () {
                    diContainer<AppRouter>().router.refresh();
                  });
                },
              ),
            ],
            child: MaterialApp.router(
              title: 'Flutter Skeleton',
              debugShowCheckedModeBanner: false,
              routerConfig: diContainer<AppRouter>().router,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(
                colorSchemeSeed: Colors.blue,
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
