class UserProfile {
  const UserProfile({required this.id, required this.name, required this.email, required this.phone});

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
      );

  final String id;
  final String name;
  final String email;
  final String phone;

  UserProfile copyWith({String? name, String? phone}) =>
      UserProfile(id: id, name: name ?? this.name, email: email, phone: phone ?? this.phone);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone};

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}
