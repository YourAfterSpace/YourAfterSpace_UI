/// Model for user profile sent to POST /v1/user/profile
class UserProfile {
  final String? address;
  final String? bio;
  final String city;
  final String? company;
  final String? country;
  final String dateOfBirth;
  final String gender;
  final String? phoneNumber;

  UserProfile({
    this.address,
    this.bio,
    required this.city,
    this.company,
    this.country,
    required this.dateOfBirth,
    required this.gender,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'bio': bio,
      'city': city,
      'company': company,
      'country': country,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
  }
}
