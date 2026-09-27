/// Represents a student's profile stored in Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final List<String> skillsToTeach;
  final List<String> skillsToLearn;
  final String profileImageUrl;
  final int credits;
  final double averageRating;
  final int totalRatings;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.bio = '',
    this.skillsToTeach = const [],
    this.skillsToLearn = const [],
    this.profileImageUrl = '',
    this.credits = 0,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  // Converts Firestore document data into a UserModel.
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      skillsToTeach: List<String>.from(map['skillsToTeach'] ?? []),
      skillsToLearn: List<String>.from(map['skillsToLearn'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
      credits: map['credits'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
    );
  }

  // Converts a UserModel into a Map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'skillsToTeach': skillsToTeach,
      'skillsToLearn': skillsToLearn,
      'profileImageUrl': profileImageUrl,
      'credits': credits,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  // Returns a copy of this profile with selected fields updated.
  UserModel copyWith({
    String? name,
    String? bio,
    List<String>? skillsToTeach,
    List<String>? skillsToLearn,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      bio: bio ?? this.bio,
      skillsToTeach: skillsToTeach ?? this.skillsToTeach,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      credits: credits,
      averageRating: averageRating,
    );
  }
}
