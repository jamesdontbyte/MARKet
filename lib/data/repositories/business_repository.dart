import '../../domain/models/business.dart';
import '../services/mock_business_service.dart';

/// Single source of truth for the signed-in MSME's business profile.
abstract interface class BusinessRepository {
  Future<Business> getBusiness({bool forceRefresh = false});

  DemoScenario get scenario;
  set scenario(DemoScenario value);
}

class MockBusinessRepository implements BusinessRepository {
  MockBusinessRepository({required MockBusinessService service})
      : _service = service;

  final MockBusinessService _service;
  Business? _cache;
  DemoScenario _scenario = DemoScenario.verifiedNoReviews;

  @override
  DemoScenario get scenario => _scenario;

  @override
  set scenario(DemoScenario value) {
    if (value == _scenario) return;
    _scenario = value;
    _cache = null;
  }

  @override
  Future<Business> getBusiness({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    return _cache = await _service.fetchBusiness(_scenario);
  }
}
