import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/filter_state.dart';
import 'package:image_picker/image_picker.dart';

// 色選択をサポートするカテゴリ
const _colorSupportedCategories = {
  IconCategory.flower,
  IconCategory.foliage,
  IconCategory.vegetation,
  IconCategory.scenery,
};

class PostRepository {
  final _client = Supabase.instance.client;

  Future<List<Post>> fetchPosts(FilterState filter) async {
    var query = _client.from('posts_view').select();

    // 大項目（単一選択）
    if (filter.selectedCategory != null) {
      final cat = filter.selectedCategory!;
      final subs = filter.selectedSubcategories[cat];

      if (subs == null || subs.isEmpty) {
        query = query.eq('icon_category', cat.name);
      } else if (subs.length == 1) {
        query = query
            .eq('icon_category', cat.name)
            .eq('icon_status', subs.first);
      } else {
        // 複数小項目は OR で展開
        final orParts = subs
            .map((s) => 'and(icon_category.eq.${cat.name},icon_status.eq.$s)')
            .join(',');
        query = query.or(orParts);
      }

      // 色フィルタは色対応カテゴリのみ適用
      if (filter.selectedColors.isNotEmpty &&
          _colorSupportedCategories.contains(cat)) {
        query = query.inFilter('icon_color', filter.selectedColors.toList());
      }
    }

    if (filter.isColonyOnly) {
      query = query.eq('is_colony', true);
    }

    final rows = await query;
    var posts = rows.map((row) => Post.fromJson(row)).toList();

    if (filter.selectedYears.isNotEmpty) {
      posts = posts
          .where((p) => filter.selectedYears.contains(p.shotAt.year))
          .toList();
    }

    posts = posts
        .where((p) => _inMmDdRange(p.shotAt, filter.rangeStart, filter.rangeEnd))
        .toList();

    return posts;
  }

  Future<String> uploadPhoto(XFile photo) async {
    final bytes = await photo.readAsBytes();
    final ext = photo.name.split('.').last.toLowerCase();
    final path = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('post-photos').uploadBinary(path, bytes);
    return _client.storage.from('post-photos').getPublicUrl(path);
  }

  Future<void> insertPost(Post post) async {
    await _client.from('posts').insert(post.toJson());
  }

  bool _inMmDdRange(DateTime shotAt, DateTime rangeStart, DateTime rangeEnd) {
    final mmdd = shotAt.month * 100 + shotAt.day;
    final start = rangeStart.month * 100 + rangeStart.day;
    final end = rangeEnd.month * 100 + rangeEnd.day;
    if (start <= end) {
      return mmdd >= start && mmdd <= end;
    } else {
      return mmdd >= start || mmdd <= end;
    }
  }
}
