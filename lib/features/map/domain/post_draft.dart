import 'package:image_picker/image_picker.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';

class PostDraft {
  final XFile? photoFile;
  final double? latitude;
  final double? longitude;
  final DateTime? shotAt;
  final IconCategory? iconCategory;
  final String? iconStatus;
  final String? iconColor;
  final bool isColony;
  final List<String> plantTags;
  final List<String> locationTags;

  const PostDraft({
    this.photoFile,
    this.latitude,
    this.longitude,
    this.shotAt,
    this.iconCategory,
    this.iconStatus,
    this.iconColor,
    this.isColony = false,
    this.plantTags = const [],
    this.locationTags = const [],
  });

  PostDraft copyWith({
    XFile? photoFile,
    double? latitude,
    double? longitude,
    DateTime? shotAt,
    IconCategory? iconCategory,
    String? iconStatus,
    String? iconColor,
    bool? isColony,
    List<String>? plantTags,
    List<String>? locationTags,
  }) {
    return PostDraft(
      photoFile: photoFile ?? this.photoFile,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shotAt: shotAt ?? this.shotAt,
      iconCategory: iconCategory ?? this.iconCategory,
      iconStatus: iconStatus ?? this.iconStatus,
      iconColor: iconColor ?? this.iconColor,
      isColony: isColony ?? this.isColony,
      plantTags: plantTags ?? this.plantTags,
      locationTags: locationTags ?? this.locationTags,
    );
  }

  bool get hasLocation => latitude != null && longitude != null && shotAt != null;
}