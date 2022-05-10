class User {
  int? id;
  String login;
  String token;
  int active;

  User(
      {this.id,
      required this.login,
      required this.token,
      required this.active});

  factory User.fromMap(Map<String, dynamic> json) => User(
      id: json["id"],
      login: json["login"],
      token: json["token"],
      active: json["active"]);

  Map<String, dynamic> toMap() =>
      {"login": login, "token": token, "active": active};
}
