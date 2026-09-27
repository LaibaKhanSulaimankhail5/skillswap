import '../../data/models/user_model.dart';

class BadgeInfo {
  final String emoji;
  final String label;
  const BadgeInfo(this.emoji, this.label);
}

/// Computes which achievement badges a student has earned, based on their
/// current credits and ratings. Badges are derived on the fly — nothing
/// extra needs to be stored in Firestore.
class BadgeHelper {
  static List<BadgeInfo> badgesFor(UserModel user) {
    final badges = <BadgeInfo>[];

    if (user.totalRatings >= 1) {
      badges.add(const BadgeInfo('🌱', 'First Exchange'));
    }
    if (user.credits >= 25) {
      badges.add(const BadgeInfo('⭐', 'Helpful Star'));
    }
    if (user.credits >= 100) {
      badges.add(const BadgeInfo('🏆', 'Skill Master'));
    }
    if (user.totalRatings >= 5) {
      badges.add(const BadgeInfo('🤝', 'Community Favorite'));
    }
    if (user.averageRating >= 4.5 && user.totalRatings >= 3) {
      badges.add(const BadgeInfo('💎', 'Top Rated'));
    }

    return badges;
  }
}
