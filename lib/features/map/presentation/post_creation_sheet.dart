import 'dart:typed_data';
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
  const _IconSpec({
    required this.label,
    this.statuses = const [],
    this.colors = const [],
  });
}

const _iconSpecs = <IconCategory, _IconSpec>{
  IconCategory.flower: _IconSpec(
    label: '花',
    statuses: ['つぼみ', '五分咲き', '満開', '散り始め'],
    colors: [
      'カラフル',
      '白',
      '赤',
      'ピンク',
      '黄色',
      'クリーム色',
      'オレンジ',
      '緑',
      '青',
      '紫',
      '黒',
    ],
  ),
  IconCategory.foliage: _IconSpec(
    label: '紅葉・枯れ',
    statuses: ['紅葉はじまり', '紅葉最盛期', '紅葉終わり', '枯れ・草紅葉'],
    colors: ['黄色', 'オレンジ', '赤', '茶色', '枯草色'],
  ),
  IconCategory.berry: _IconSpec(
    label: '実',
    statuses: ['実'],
    colors: ['カラフル', '白', '赤', 'ピンク', '黄色', 'オレンジ', '緑', '青', '紫', '黒'],
  ),
  IconCategory.snow: _IconSpec(label: '雪', statuses: ['雪']),
  IconCategory.plant: _IconSpec(
    label: '植物',
    statuses: ['葉っぱ', 'コケ'],
    colors: ['黄緑', '緑', '深緑', '黄色'],
  ),
  IconCategory.mushroom: _IconSpec(
    label: 'きのこ',
    statuses: ['きのこ'],
    colors: ['カラフル', '白', '赤', 'ピンク', '黄色', 'オレンジ', '茶色'],
  ),
  IconCategory.mountain: _IconSpec(
    label: '山・景色',
    statuses: ['山'],
    colors: ['緑', '白', '青', '赤・オレンジ'],
  ),
  IconCategory.hut: _IconSpec(label: '山小屋', statuses: ['有人', '無人']),
  IconCategory.water: _IconSpec(label: '水場', statuses: ['水あり', '少ない', '枯れ']),
  IconCategory.trailDamage: _IconSpec(
    label: '崩落・通行止め',
    statuses: ['通行可能', '要注意', '通行不可'],
  ),
  IconCategory.other: _IconSpec(label: 'その他'),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
        Text('新規投稿', style: Theme.of(context).textTheme.titleLarge),
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
        final spec = _iconSpecs[draft.iconCategory];
        return draft.iconCategory != null &&
            draft.iconStatus != null &&
            (spec == null || spec.colors.isEmpty || draft.iconColor != null);
      case 2:
      case 3:
        return true;
      default:
        return false;
    }
  }
}

class _Step1Photo extends StatefulWidget {
  const _Step1Photo({required this.draft, required this.notifier});
  final PostDraft draft;
  final PostCreationNotifier notifier;
  @override
  State<_Step1Photo> createState() => _Step1PhotoState();
}

class _Step1PhotoState extends State<_Step1Photo> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.draft.photoFile != null) _loadBytes();
  }

  @override
  void didUpdateWidget(_Step1Photo old) {
    super.didUpdateWidget(old);
    if (widget.draft.photoFile?.path != old.draft.photoFile?.path) _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await widget.draft.photoFile!.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
  }

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
            await widget.notifier.pickPhoto();
          },
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(widget.draft.photoFile == null ? '写真を選択' : '写真を変更'),
        ),
        const SizedBox(height: 16),
        if (widget.draft.photoFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _imageBytes != null
                ? Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
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
                  value: widget.draft.latitude?.toStringAsFixed(6) ?? '未取得',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '経度',
                  value: widget.draft.longitude?.toStringAsFixed(6) ?? '未取得',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '撮影日時',
                  value: widget.draft.shotAt == null
                      ? '未取得'
                      : '${widget.draft.shotAt!.year}/${widget.draft.shotAt!.month.toString().padLeft(2, '0')}/${widget.draft.shotAt!.day.toString().padLeft(2, '0')} '
                            '${widget.draft.shotAt!.hour.toString().padLeft(2, '0')}:${widget.draft.shotAt!.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ),
        if (widget.draft.photoFile != null && !widget.draft.hasLocation) ...[
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
  const _Step2Icon({required this.draft, required this.notifier});
  final PostDraft draft;
  final PostCreationNotifier notifier;

  static const _categoryIcons = <IconCategory, IconData>{
    IconCategory.flower: Icons.local_florist,
    IconCategory.foliage: Icons.eco,
    IconCategory.berry: Icons.grain,
    IconCategory.snow: Icons.ac_unit,
    IconCategory.plant: Icons.grass,
    IconCategory.mushroom: Icons.emoji_nature,
    IconCategory.mountain: Icons.landscape,
    IconCategory.hut: Icons.cottage,
    IconCategory.water: Icons.water_drop,
    IconCategory.trailDamage: Icons.warning_amber,
    IconCategory.other: Icons.more_horiz,
  };

  // 群落トグルを表示するカテゴリ（植物系のみ）
  static const _colonyCategories = {
    IconCategory.flower,
    IconCategory.foliage,
    IconCategory.berry,
    IconCategory.snow,
    IconCategory.plant,
    IconCategory.mushroom,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spec = draft.iconCategory == null
        ? null
        : _iconSpecs[draft.iconCategory!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── カテゴリ選択グリッド ──────────────────────────
        Text('カテゴリ', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.8,
          children: IconCategory.values.map((cat) {
            return ChoiceChip(
              selected: draft.iconCategory == cat,
              avatar: Icon(_categoryIcons[cat], size: 18),
              label: Text(_iconSpecs[cat]!.label),
              onSelected: (_) => notifier.selectCategory(cat),
            );
          }).toList(),
        ),

        // ── 状態チップ ────────────────────────────────────
        if (spec != null && spec.statuses.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('状態', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: spec.statuses
                .map(
                  (s) => ChoiceChip(
                    label: Text(s),
                    selected: draft.iconStatus == s,
                    onSelected: (_) => notifier.selectStatus(s),
                  ),
                )
                .toList(),
          ),
        ],

        // ── 色チップ（色ありカテゴリのみ）────────────────
        if (spec != null && spec.colors.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('色', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: spec.colors
                .map(
                  (c) => ChoiceChip(
                    label: Text(c),
                    selected: draft.iconColor == c,
                    onSelected: (_) => notifier.selectColor(c),
                  ),
                )
                .toList(),
          ),
        ],

        // ── 群落トグル（植物系カテゴリのみ）─────────────
        if (draft.iconCategory != null &&
            _colonyCategories.contains(draft.iconCategory)) ...[
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('群落（まとまって生えている）'),
            subtitle: const Text('複数株が密集している場合にオン'),
            value: draft.isColony,
            onChanged: notifier.setColony,
          ),
        ],
      ],
    );
  }
}

class _Step3Tags extends StatefulWidget {
  const _Step3Tags({required this.draft, required this.notifier});
  final PostDraft draft;
  final PostCreationNotifier notifier;
  @override
  State<_Step3Tags> createState() => _Step3TagsState();
}

class _Step3TagsState extends State<_Step3Tags> {
  final _plantController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _plantController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitPlant() {
    final tag = _plantController.text.trim();
    if (tag.isEmpty) return;
    widget.notifier.addPlantTag(tag);
    _plantController.clear();
  }

  void _submitLocation() {
    final tag = _locationController.text.trim();
    if (tag.isEmpty) return;
    widget.notifier.addLocationTag(tag);
    _locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TagSection(
          title: '植物名タグ',
          hint: 'カタカナまたは英語で入力（例：ニッコウキスゲ、Edelweiss）',
          controller: _plantController,
          onSubmit: _submitPlant,
          tags: widget.draft.plantTags,
          onDelete: widget.notifier.removePlantTag,
        ),
        const SizedBox(height: 20),
        _TagSection(
          title: '場所タグ',
          hint: '日本語または英語で入力（例：立山、Tateyama）',
          controller: _locationController,
          onSubmit: _submitLocation,
          tags: widget.draft.locationTags,
          onDelete: widget.notifier.removeLocationTag,
        ),
      ],
    );
  }
}

class _Step4Confirm extends StatelessWidget {
  const _Step4Confirm({required this.draft});
  final PostDraft draft;
  @override
  Widget build(BuildContext context) {
    return const Text('Step 4: 確認');
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({
    required this.title,
    required this.hint,
    required this.controller,
    required this.onSubmit,
    required this.tags,
    required this.onDelete,
  });
  final String title;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final List<String> tags;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(hint, style: textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'タグを入力してEnter',
                  isDense: true,
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onSubmit, child: const Text('追加')),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags
                .map(
                  (tag) =>
                      Chip(label: Text(tag), onDeleted: () => onDelete(tag)),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
