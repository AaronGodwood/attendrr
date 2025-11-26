// Friend model
class FriendModel {
  final String id;
  final String name;
  final String email;

  FriendModel({required this.id, required this.name, required this.email});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
