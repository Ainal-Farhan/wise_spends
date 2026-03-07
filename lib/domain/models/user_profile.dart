class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? occupation;
  final String? address;
  final String? profileImageUrl;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.occupation,
    this.address,
    this.profileImageUrl,
    required this.dateCreated,
    required this.dateUpdated,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? occupation,
    String? address,
    String? profileImageUrl,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'occupation': occupation,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'dateUpdated': dateUpdated.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      occupation: map['occupation'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
      dateUpdated: DateTime.fromMillisecondsSinceEpoch(map['dateUpdated']),
    );
  }

  factory UserProfile.fromCmmnUser(dynamic cmmnUser) {
    // Use dynamic to avoid direct reference to generated class
    return UserProfile(
      id: cmmnUser.id,
      name: cmmnUser.name,
      email: cmmnUser.email,
      phone: cmmnUser.phoneNumber,
      occupation: cmmnUser.occupation,
      address: cmmnUser.address,
      profileImageUrl: cmmnUser.profileImageUrl,
      dateCreated: cmmnUser.dateCreated,
      dateUpdated: cmmnUser.dateUpdated,
    );
  }
}