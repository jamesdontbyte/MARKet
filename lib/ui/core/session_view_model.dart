import 'package:flutter/foundation.dart';

import '../../domain/models/personal_account.dart';

/// Who is signed in and whether onboarding is finished. Drives routing.
class SessionViewModel extends ChangeNotifier {
  PersonalAccount? _account;
  bool _onboarded = false;

  PersonalAccount? get account => _account;
  bool get isOnboarded => _onboarded;

  void completeOnboarding(PersonalAccount account) {
    _account = account;
    _onboarded = true;
    notifyListeners();
  }

  void updateAccount(PersonalAccount account) {
    _account = account;
    notifyListeners();
  }

  void signOut() {
    _account = null;
    _onboarded = false;
    notifyListeners();
  }
}
