import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/app_language_provider.dart';
import 'app_strings.dart';

extension AppStringsContext on BuildContext {
  AppStrings get strings => watch<AppLanguageProvider>().strings;

  AppLanguageProvider get appLanguage => read<AppLanguageProvider>();
}
