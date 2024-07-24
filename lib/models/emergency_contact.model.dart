class EmergencyContact {
  final String name;
  final String phoneNumber;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory EmergencyContact.fromFirestore(Map<String, dynamic> data) {
    return EmergencyContact(
      name: data['name'],
      phoneNumber: data['phoneNumber'],
    );
  }
}
