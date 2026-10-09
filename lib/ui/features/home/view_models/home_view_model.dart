import 'package:flutter/foundation.dart';

import '../../../../data/repositories/business_repository.dart';
import '../../../../data/services/mock_business_service.dart';
import '../../../../domain/models/business.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required BusinessRepository repository})
      : _repository = repository;

  final BusinessRepository _repository;

  Business? _business;
  Business? get business => _business;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DemoScenario get scenario => _repository.scenario;

  Future<void> load({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _business = await _repository.getBusiness(forceRefresh: forceRefresh);
    } catch (_) {
      _error = 'Your business profile could not be loaded. '
          'Check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchScenario(DemoScenario scenario) async {
    _repository.scenario = scenario;
    await load(forceRefresh: true);
  }

  /// Installs a business created during onboarding.
  void setBusiness(Business business) {
    _business = business;
    _error = null;
    notifyListeners();
  }

  /// Applies an edit made from Promo Studio, Account, etc.
  void update(Business Function(Business current) change) {
    final current = _business;
    if (current == null) return;
    _business = change(current);
    notifyListeners();
  }

  /// Clears the business (sign out).
  void clear() {
    _business = null;
    notifyListeners();
  }
}
