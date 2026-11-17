import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/filter_state.dart';
import 'package:image_picker/image_picker.dart';
class PostRepository {
  final _client = Supabase.instance.client;

  Future <List<Post>> fetchPosts(FilterState filter) async {
    var query = _client.from('posts_view').select();

    // カテゴリ × 小項目の OR 条件
    // 例: (花 AND つぼみ) OR (花 AND 満開) OR (紅葉) OR (景色 AND 山)
    if (filter.selectedCategories.isNotEmpty) {
      final orParts = <String>[];
      for (final cat in filter.selectedCategories) {
        final subs = filter.selectedSubcategories[cat];
        if (subs == null || subs.isEmpty) {
          // 小項目未選択 → カテゴリ全体にマッチ
          orParts.add('icon_category.eq.${cat.name}');
        } else {
          // 小項目選択あり → (カテゴリ AND 小項目) ごとに条件追加
          for (final sub in subs) {
            orParts.add('and(icon_category.eq.${cat.name},icon_status.eq.$sub)');
          }
        }
      }
      if (orParts.length == 1 && !orParts.first.startsWith('and(')) {
        // 単純な1カテゴリ指定
        query = query.eq('icon_category', filter.selectedCategories.first.name);
      } else {
        query = query.or(orParts.join(','));
      }
    }

    if (filter.selectedColors.isNotEmpty) {
      query = query.inFilter(
        'icon_color',
        filter.selectedColors.toList(),
      );
    }

    if (filter.isColonyOnly) {
      query = query.eq('is_colony', true);
    }

    final rows = await query;
    print('fetchPost: ${rows.length} 件、内容：$rows');
    var posts = rows.map((row) => Post.fromJson(row)).toList();

    if (filter.selectedYears.isNotEmpty) {
      posts = posts.where((p) => filter.selectedYears.contains(p.shotAt.year)).toList();
    }

    posts = posts.where((p) => _inMmDdRange(p.shotAt, filter.rangeStart, filter.rangeEnd)).toList();

    return posts;

  }

  Future<String> uploadPhoto(XFile photo) async {
  final bytes = await photo.readAsBytes();
  final ext = photo.name.split('.').last.toLowerCase();
  final path = '${DateTime.now().millisecondsSinceEpoch}.$ext';
  await _client.storage.from('post-photos').uploadBinary(path, bytes);
  return _client.storage.from('podt-photos').getPublicUrl(path);
  }

  Future<void> insertPost(Post post) async {
    await _client.from('posts').insert(post.toJson());
  }

  bool _inMmDdRange(DateTime shotAt, DateTime rangeStart, DateTime rangeEnd) {
    final mmdd = shotAt.month * 100 + shotAt.day;
    final start = rangeStart.month * 100 + rangeStart.day;
    final end = rangeEnd.month * 100 + rangeEnd.day;
    if (start <= end){
      return mmdd >= start && mmdd <= end;
    } else {
      return mmdd >= start || mmdd <= end;
    }
  }





}

