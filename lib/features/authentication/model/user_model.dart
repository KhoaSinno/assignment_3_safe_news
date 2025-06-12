class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  UserModel({required this.id, required this.email, this.name, this.photoUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }
}
