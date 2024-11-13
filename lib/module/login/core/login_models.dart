class UserGetAll {
  final String id;
  final String name;
  final String email;

  UserGetAll({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserGetAll.fromJson(Map<String, dynamic> json) {
    return UserGetAll(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
