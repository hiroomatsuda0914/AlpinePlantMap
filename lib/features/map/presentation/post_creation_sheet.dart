import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/post_draft.dart';
import 'package:alpine_plant_map/features/map/presentation/post_creation_notifier.dart';


// ── アイコン仕様データ ──────────────────────────────────────────────────────────

class _IconSpec {
  final String label;
  final List<String> statuses;
  final List<String> colors;
  const _IconSpec({required this.label, this.statuses = const [], this.colors = const []});}

  const _iconSpecs = <IconCategory, _IconSpec>{
  IconCategory.flower:   _IconSpec(label: '花',       statuses: ['つぼみ', '五分咲き', '満開', '散り始め'],            colors: ['カラフル', '白', '赤', 'ピンク', '黄色', 'クリーム色', 'オレンジ', '緑', '青', '紫', '黒']),
  IconCategory.foliage:  _IconSpec(label: '紅葉・枯れ', statuses: ['紅葉はじまり', '紅葉最盛期', '紅葉終わり', '枯れ・草紅葉'], colors: ['黄色', 'オレンジ', '赤', '茶色', '枯草色']),
  IconCategory.berry:    _IconSpec(label: '実',        statuses: ['実'],                                           colors: ['カラフル', '白', '赤', 'ピンク', '黄色', 'オレンジ', '緑', '青', '紫', '黒']),
  IconCategory.snow:     _IconSpec(label: '雪',        statuses: ['雪']),
  IconCategory.plant:    _IconSpec(label: '植物',      statuses: ['葉っぱ', 'コケ'],                               colors: ['黄緑', '緑', '深緑', '黄色']),
  IconCategory.mushroom: _IconSpec(label: 'きのこ',    statuses: ['きのこ'],                                       colors: ['カラフル', '白', '赤', 'ピンク', '黄色', 'オレンジ', '茶色']),
  IconCategory.mountain: _IconSpec(label: '山・景色',  statuses: ['山'],                                           colors: ['緑', '白', '青', '赤・オレンジ']),
  IconCategory.hut:      _IconSpec(label: '山小屋',    statuses: ['有人', '無人']),
  IconCategory.other:    _IconSpec(label: 'その他'),
  };


  // ── メインシート ──────────────────────────────────────────────────────────

class PostCreationSheet extends ConsumerStatefulWidget {
  const PostCreationSheet({super.key});
  @override
  ConsumerState<PostCreationSheet> createState() => _PostCreationSheetState();
}

class _PostCreationSheetState extends ConsumerState<PostCreationSheet> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(postDraftProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,

      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color:context.Theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column (
            children: [
              Container(
                ,)
            ],)
      }

          ],
        ),
      ),
    );
  }