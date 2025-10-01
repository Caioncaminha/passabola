class Usermodel {
  final String uid;
  final String gmail;
  final String name;
  final String role;
  final String createdAt;
  final String photoUrl;
  final String team;

  Usermodel({
    required this.uid,
    required this.gmail,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.photoUrl,
    required this.team,
  });

  factory Usermodel.fromMap(Map<String, dynamic> map) {
    return Usermodel(
      uid: map['uid'],
      gmail: map['gmail'],
      name: map['name'],
      role: map['role'],
      createdAt: map['createdAt'],
      photoUrl: map['photoUrl'],
      team: map['team'],
    );
  }
}
