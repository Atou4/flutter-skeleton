import 'package:get_it/get_it.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/di/modules/di_bloc_module.dart';
import 'package:flutter_skeleton/di/modules/di_dio_module.dart';
import 'package:flutter_skeleton/di/modules/di_service_module.dart';

class Injector {
  Injector._();
  static GetIt instance = diContainer;

  static Future<void> init() async {
    ServiceModule.init();
    DioModule.setupBaseDio();
    BlocModule.init();
    DioModule.setupAuthInterceptor();
  }

  static void reset() {
    instance.reset();
  }

  static void resetLazySingleton() {
    instance.resetLazySingleton();
  }
}
