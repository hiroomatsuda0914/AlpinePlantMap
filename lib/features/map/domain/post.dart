enum IconCategory {
  flower,
  foliage,
  berry,
  snow,
  plant,
  mushroom,
  mountain,
  hut,
  other,
}

class Post {
  final String id;
  final String? userId;
  final double latitude;
  final double longitude;
  final DateTime shotAt;
  final String photoUrl;
  final String thumbnailUrl;
  final IconCategory iconCategory;
  final String? iconStatus;
  final String iconColor;
  final bool isColony;
  final List<String> plantTags;
  final List<String> locationTags;
  final DateTime createdAt;

const Post({
    required this.id,
    this.userId,
    required this.latitude,
    required this.longitude,
    required this.shotAt,
    required this.photoUrl,
    required this.thumbnailUrl,
    required this.iconCategory,
    this.iconStatus,
    required this.iconColor,
    required this.isColony,
    required this.plantTags,
    required this.locationTags,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final coordinates = (json['location'] as Map<String, dynamic>)['coordinates'] as List;
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
      shotAt: DateTime.parse(json['shot_at'] as String),
      photoUrl: json['photo_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      iconCategory: IconCategory.values.byName(json['icon_category'] as String),
      iconStatus: json['icon_status'] as String?,
      iconColor: json['icon_color'] as String,
      isColony: json['is_colony'] as bool,
      plantTags: List<String>.from(json['plant_tags'] as List),
      locationTags: List<String>.from(json['location_tags'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'location': 'SRID=4326;POINT($longitude $latitude)',
    'shot_at': shotAt.toIso8601String(),
    'photo_url': photoUrl,
    'thumbnail_url': thumbnailUrl,
    'icon_category': iconCategory.name,
    'icon_status': iconStatus,
    'icon_color': iconColor,
    'is_colony': isColony,
    'plant_tags': plantTags,
    'location_tags': locationTags,
  };



}