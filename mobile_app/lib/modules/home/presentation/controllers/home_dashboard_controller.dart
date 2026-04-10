import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/usecases/get_home_dashboard_use_case.dart';

class HomeDashboardController extends ChangeNotifier {
  HomeDashboardController({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase;

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;

  HomeDashboard? _dashboard;
  bool _isLoading = false;
  String? _errorMessage;

  HomeDashboard? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasDashboard => _dashboard != null;

  Future<void> loadDashboard({
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _dashboard = await _getHomeDashboardUseCase.execute();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load the dashboard right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() {
    return loadDashboard(
      silent: false,
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
