/// The owner's personal account (spec §2.1). Only fields the spec requires.
class PersonalAccount {
  const PersonalAccount({
    required this.fullName,
    required this.email,
    this.mobile = '',
  });

  final String fullName;
  final String email;
  final String mobile;

  PersonalAccount copyWith({String? fullName, String? email, String? mobile}) =>
      PersonalAccount(
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
      );
}
