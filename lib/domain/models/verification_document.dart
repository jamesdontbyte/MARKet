/// Documents required for business verification (spec §4).
enum DocumentType {
  dti('DTI certificate', 'DTI certificate / registration'),
  bir('BIR certificate', 'BIR certificate / registration'),
  mayorsPermit("Mayor's permit", "Mayor's Permit or applicable business permit"),
  governmentId('Government ID', 'Government-issued ID');

  const DocumentType(this.label, this.description);
  final String label;
  final String description;
}

class VerificationDocument {
  const VerificationDocument({required this.type, this.filePath});

  final DocumentType type;

  /// Local path of the uploaded photo/scan; null until uploaded.
  final String? filePath;

  bool get isUploaded => filePath != null;
}
