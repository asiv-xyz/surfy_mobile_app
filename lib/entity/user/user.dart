class User {
  User({
    required this.id,
    required this.createdAt,
    required this.userName,
    required this.sso,
    required this.updatedAt,
  });

  final String id;
  final DateTime createdAt;
  final String userName;
  final String sso;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map["id"],
      createdAt: DateTime.parse(map["createdAt"]),
      userName: map["userName"],
      sso: map["sso"],
      updatedAt: map["updatedAt"] == null ? null : DateTime.parse(map["updatedAt"])
    );
  }

  @override
  String toString() {
    return {
      "id": id,
      "createdAt": createdAt,
      "userName": userName,
      "sso": sso,
      "updatedAt": updatedAt,
    }.toString();
  }
}