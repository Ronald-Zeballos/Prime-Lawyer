class SessionUser {
  const SessionUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.role,
    required this.type,
    required this.plan,
    required this.tokensAvailable,
    required this.isActive,
  });

  final String id;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final String? bio;
  final String role;
  final String type;
  final String plan;
  final int tokensAvailable;
  final bool isActive;

  String get fullName => '$firstName $lastName'.trim();
  String get displayLabel =>
      displayName.trim().isEmpty ? fullName : displayName;
}
