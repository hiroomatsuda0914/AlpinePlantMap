import 'package:exif/exif.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/post_draft.dart';
import 'package:alpine_plant_map/features/map/data/post_repository.dart';

class PostCreationNotifier extends Notifier<PostDraft> {
  @override
  PostDraft build() => const PostDraft();

  Future<bool> pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return false;

    final tags = await readExifFromBytes(await picked.readAsBytes());

    final lat = _parseGps(tags['GPS GPSLatitude'], tags['GPS GPSLatitudeRef']?.printable);
    final lng = _parseGps(tags['GPS GPSLongitude'], tags['GPS GPSLongitudeRef']?.printable);
    final shotAt = _parseShotAt(tags['EXIF DateTimeOriginal']?.printable);

    state = state.copyWith(photoFile: picked, latitude: lat, longitude: lng, shotAt: shotAt);
    return state.hasLocation;
  }

  void selectCategory(IconCategory category) {
    state = PostDraft(
      photoFile: state.photoFile,
      latitude: state.latitude,
      longitude: state.longitude,
      shotAt: state.shotAt,
      iconCategory: category,
      iconStatus: null,
      iconColor: category == IconCategory.hut ? 'brown' : null,
      isColony: state.isColony,
      plantTags: state.plantTags,
      locationTags: state.locationTags,
    );
  }

  void selectStatus(String status) {
    state = state.copyWith(iconStatus: status);
  }

  void selectColor(String color) {
    state = state.copyWith(iconColor: color);
  }

  void setColony(bool isColony) {
    state = state.copyWith(isColony: isColony);
  }

    void addPlantTag(String tag) {
    if (tag.isEmpty || state.plantTags.contains(tag)) return;
    state = state.copyWith(plantTags: [...state.plantTags, tag]);
  }

  void removePlantTag(String tag) {
    state = state.copyWith(
      plantTags: state.plantTags.where((t) => t != tag).toList(),
    );
  }

  void addLocationTag(String tag) {
    if (tag.isEmpty || state.locationTags.contains(tag)) return;
    state = state.copyWith(locationTags: [...state.locationTags, tag]);
  }

  void removeLocationTag(String tag) {
    state = state.copyWith(
      locationTags: state.locationTags.where((t) => t != tag).toList(),
    );
  }

  void reset() {
    state = const PostDraft();
  }

  Future<void> submitPost() async {
    final draft = state;
    final repo = PostRepository();
    final photoUrl = await repo.uploadPhoto(draft.photoFile!);
    final post = Post(
      id: '',
      userId: null,
      latitude: draft.latitude!,
      longitude: draft.longitude!,
      shotAt: draft.shotAt!,
      photoUrl: photoUrl,
      thumbnailUrl: photoUrl,
      iconCategory: draft.iconCategory!,
      iconStatus: draft.iconStatus,
      iconColor: draft.iconColor ?? '',
      isColony: draft.isColony,
      plantTags: draft.plantTags,
      locationTags: draft.locationTags,
      createdAt: DateTime.now(),
    );
    await repo.insertPost(post);
  }


  double? _parseGps(IfdTag? tag, String? ref) {
    if (tag == null || ref == null) return null;
    final values = tag.values.toList();
    if (values.length < 3) return null;

    double ratio(dynamic v) =>
        v is Ratio ? v.numerator / v.denominator : (v as num).toDouble();

    final decimal = ratio(values[0]) + ratio(values[1]) / 60 + ratio(values[2]) / 3600;
    return (ref == 'S' || ref == 'W') ? -decimal : decimal;
  }

    DateTime? _parseShotAt(String? raw) {
    if (raw == null) return null;
    try {
      final parts = raw.split(' ');
      return DateTime.parse('${parts[0].replaceAll(':', '-')} ${parts.length > 1 ? parts[1] : '00:00:00'}');
    } catch (_) {
      return null;
    }
  }
}

final postCreationProvider = NotifierProvider<PostCreationNotifier, PostDraft>(
  PostCreationNotifier.new,
);