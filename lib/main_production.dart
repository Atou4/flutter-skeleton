import 'package:flutter_skeleton/bootstrap.dart';
import 'package:flutter_skeleton/core/configs/app_config.dart';
import 'package:flutter_skeleton/features/app/presentation/app.dart';

void main() {
  bootstrap(
    () => const App(),
    () async {
      AppConfig.configProduction();
    },
  );
}
