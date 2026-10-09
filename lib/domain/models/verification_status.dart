/// Business verification states defined in spec §4.
enum VerificationStatus {
  pending('Pending'),
  underReview('Under review'),
  verified('Verified'),
  requiresCorrection('Requires correction'),
  rejected('Rejected');

  const VerificationStatus(this.label);

  final String label;

  /// A business may only be presented as verified once review is complete.
  bool get isVerified => this == VerificationStatus.verified;
}
