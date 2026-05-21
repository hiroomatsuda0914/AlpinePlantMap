import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/filter_state.dart';

class PostRepository {
  final _client = Supabase.instance.client;

  Future <List<Post>> fetchPosts(FilterState filter) async {
    final rows = await _client.from('posts').select();
    return rows.map((row) => Post.fromJson(row)).toList();
  }
}