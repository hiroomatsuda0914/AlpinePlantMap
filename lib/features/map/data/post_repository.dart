import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/filter_state.dart';
import 'package:image_picker/image_picker.dart';
class PostRepository {
  final _client = Supabase.instance.client;

  Future <List<Post>> fetchPosts(FilterState filter) async {
    final rows = await _client.from('posts').select();
    return rows.map((row) => Post.fromJson(row)).toList();
  }

  Future<String> uploadPhoto(XFile photo) async {
  final bytes = await photo.readAsBytes();
  final ext = photo.name.split('.').last.toLowerCase();
  final path = '${DateTime.now().millisecondsSinceEpoch}.$ext';
  await _client.storage.from('post-photos').uploadBinary(path, bytes);
  return _client.storage.from('phot-photos').getPublicUrl(path);
  }

  Future<void> insertPost(Post post) async {
    await _client.from('posts').insert(post.toJson());
  }
}

