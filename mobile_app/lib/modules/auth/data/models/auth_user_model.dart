class AuthUserModel {
  const AuthUserModel({
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

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String;
    final lastName = json['lastName'] as String;
    final rawDisplayName = json['displayName'] as String?;

    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (rawDisplayName == null || rawDisplayName.trim().isEmpty)
          ? '$firstName $lastName'.trim()
          : rawDisplayName,
      firstName: firstName,
      lastName: lastName,
      bio: json['bio'] as String?,
      role: json['role'] as String,
      type: json['type'] as String,
      plan: json['plan'] as String,
      tokensAvailable: json['tokensAvailable'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
