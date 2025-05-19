class UserModel {
  String? id;
  final String? email;
  final String? username;
  final String? avatarUrl;

  UserModel({
    this.id,
    required this.email,
    required this.username,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      avatarUrl: map['avatarUrl'],
    );
  }
}