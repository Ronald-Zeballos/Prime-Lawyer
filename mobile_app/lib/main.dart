import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    PrimeLawyerApp(
      appConfig: AppConfig.fromEnvironment(),
    ),
  );
}
