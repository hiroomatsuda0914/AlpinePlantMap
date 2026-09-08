import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/data/post_repository.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/presentation/filter_notifier.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final filter = ref.watch(filterProvider);
  return PostRepository().fetchPosts(filter);
});