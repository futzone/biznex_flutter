class Role {
  String id;
  String name;
  List permissions;

  Role({this.id = '', required this.name, required this.permissions});

  factory Role.fromJson(json) {
    return Role(name: json['name'], id: json['id'], permissions: json['permissions'] ?? []);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'permissions': permissions};

  static List<String> permissionList = [
    "ofitsant",
    // "admin",
  ];
}
