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
    final draft = ref.watch(postCreationProvider);
    final notifier = ref.read(postCreationProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildHeader(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildStepBody(draft, notifier),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildFooter(context, draft),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildHeader(BuildContext context) {
    const titles = ['写真', 'アイコン', 'タグ', '確認'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '新規投稿',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text('Step ${_step + 1} / 4: ${titles[_step]}'),
      ],
    );
  }
  Widget _buildStepBody(PostDraft draft, PostCreationNotifier notifier) {
    switch (_step) {
      case 0:
        return _Step1Photo(draft: draft, notifier: notifier);
      case 1:
        return _Step2Icon(draft: draft, notifier: notifier);
      case 2:
        return _Step3Tags(draft: draft, notifier: notifier);
      case 3:
        return _Step4Confirm(draft: draft);
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildFooter(BuildContext context, PostDraft draft) {
    return Row(
      children: [
        if (_step > 0)
          OutlinedButton(
            onPressed: () => setState(() => _step--),
            child: const Text('戻る'),
          ),
        const Spacer(),
        FilledButton(
          onPressed: _canGoNext(draft)
              ? () {
                  if (_step < 3) {
                    setState(() => _step++);
                  } else {
                    Navigator.pop(context);
                  }
                }
              : null,
          child: Text(_step == 3 ? '閉じる' : '次へ'),
        ),
      ],
    );
  }
  bool _canGoNext(PostDraft draft) {
    switch (_step) {
      case 0:
        return draft.photoFile != null && draft.hasLocation;
      case 1:
        return draft.iconCategory != null &&
            draft.iconStatus != null &&
            (draft.iconCategory == IconCategory.hut || draft.iconColor != null);
      case 2:
      case 3:
        return true;
      default:
        return false;
    }
  }
}

class _Step1Photo extends StatelessWidget {
  const _Step1Photo({
    required this.draft,
    required this.notifier,
  });

  final PostDraft draft;
  final PostCreationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '写真を選択すると、EXIFから撮影位置と撮影日時を自動で読み取ります。',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            await notifier.pickPhoto();
          },
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(
            draft.photoFile == null ? '写真を選択' : '写真を変更',
          ),
        ),
        const SizedBox(height: 16),
        if (draft.photoFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              draft.photoFile!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: '緯度',
                  value: draft.latitude?.toStringAsFixed(6) ?? '未取得',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '経度',
                  value: draft.longitude?.toStringAsFixed(6) ?? '未取得',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '撮影日時',
                  value: draft.shotAt == null
                      ? '未取得'
                      : '${draft.shotAt!.year}/${draft.shotAt!.month.toString().padLeft(2, '0')}/${draft.shotAt!.day.toString().padLeft(2, '0')} '
                          '${draft.shotAt!.hour.toString().padLeft(2, '0')}:${draft.shotAt!.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ),
        if (draft.photoFile != null && !draft.hasLocation) ...[
          const SizedBox(height: 12),
          Text(
            '位置情報または撮影日時が含まれていない写真は投稿できません。',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _Step2Icon extends StatelessWidget {
  const _Step2Icon({
    required this.draft,
    required this.notifier,
  });
  final PostDraft draft;
  final PostCreationNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return const Text('Step 2: アイコン');
  }
}
class _Step3Tags extends StatelessWidget {
  const _Step3Tags({
    required this.draft,
    required this.notifier,
  });
  final PostDraft draft;
  final PostCreationNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return const Text('Step 3: タグ');
  }
}
class _Step4Confirm extends StatelessWidget {
  const _Step4Confirm({
    required this.draft,
  });
  final PostDraft draft;
  @override
  Widget build(BuildContext context) {
    return const Text('Step 4: 確認');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}