class UserModel {
  final int id;
  final String name;
  final String email;
  final Set<String> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Convert the list of permissions from the API into a Set for fast lookups
    final List<dynamic> permissionsList = json['permissions'] ?? [];
    final Set<String> permissionsSet = permissionsList.map((p) => p.toString()).toSet();
    
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      permissions: permissionsSet,
    );
  }
}