/// The signed-in user's row in `profiles`, with the role name joined in.
class Profile {
  const Profile({
    required this.id,
    required this.role,
    this.email,
    this.firstname,
    this.lastname,
  });

  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;

  /// 'admin' or 'customer'.
  final String role;

  bool get isAdmin => role == 'admin';

  String get displayName {
    final full = [
      firstname,
      lastname,
    ].where((s) => s != null && s.trim().isNotEmpty).join(' ');
    return full.isNotEmpty ? full : (email ?? 'Account');
  }

  static const selectColumns = 'id, email, firstname, lastname, roles(role)';

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    email: json['email'] as String?,
    firstname: json['firstname'] as String?,
    lastname: json['lastname'] as String?,
    role:
        (json['roles'] as Map<String, dynamic>?)?['role'] as String? ??
        'customer',
  );
}
