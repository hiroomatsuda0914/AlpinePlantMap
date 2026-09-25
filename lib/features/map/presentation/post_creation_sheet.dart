import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/post_draft.dart';
import 'package:alpine_plant_map/features/map/presentation/post_creation_notifier.dart';

// ── カラーパレット定義 ─────────────────────────────────────────────────────────

class _ColorEntry {
  final String name;
  final String hex;
  const _ColorEntry(this.name, this.hex);
}

const _colorPalette = <_ColorEntry>[
  _ColorEntry('白',         '#F0F0F0'),
  _ColorEntry('グレー',     '#8C8C8C'),
  _ColorEntry('黒',         '#212121'),
  _ColorEntry('赤',         '#E05353'),
  _ColorEntry('オレンジ',   '#EE913B'),
  _ColorEntry('山吹色',     '#E2AA3B'),
  _ColorEntry('黄色',       '#F2D04F'),
  _ColorEntry('黄緑',       '#8DBF54'),
  _ColorEntry('緑',         '#5EB165'),
  _ColorEntry('深緑',       '#3B8444'),
  _ColorEntry('水色',       '#2DB0C2'),
  _ColorEntry('青',         '#3D88D8'),
  _ColorEntry('紺',         '#2D6CA8'),
  _ColorEntry('薄紫',       '#AB68C6'),
  _ColorEntry('紫',         '#6B3293'),
  _ColorEntry('濃いピンク', '#D13F73'),
  _ColorEntry('薄いピンク', '#E57399'),
  _ColorEntry('薄い茶色',   '#AB9289'),
  _ColorEntry('茶色',       '#5C453E'),
];

// ── アイコン仕様データ ─────────────────────────────────────────────────────────

class _IconSpec {
  final String label;
  final List<String> statuses;
  final Set<String> availableColors; // hex codes; empty = 色選択なし
  const _IconSpec({
    required this.label,
    this.statuses = const [],
    this.availableColors = const {},
  });
}

const _iconSpecs = <IconCategory, _IconSpec>{
  IconCategory.flower: _IconSpec(
    label: '花',
    statuses: ['つぼみ', '五分咲き', '満開', '散り始め'],
    availableColors: {
      '#F0F0F0', '#212121', '#E05353', '#EE913B', '#E2AA3B',
      '#F2D04F', '#8DBF54', '#5EB165', '#3B8444', '#2DB0C2',
      '#3D88D8', '#2D6CA8', '#AB68C6', '#6B3293', '#D13F73',
      '#E57399', '#AB9289', '#5C453E',
    },
  ),
  IconCategory.foliage: _IconSpec(
    label: '紅葉',
    statuses: ['序盤', '8割', '最盛期', '終り'],
    availableColors: {
      '#E05353', '#EE913B', '#E2AA3B', '#F2D04F', '#8DBF54',
      '#5EB165', '#3B8444', '#D13F73', '#E57399', '#AB9289', '#5C453E',
    },
  ),
  IconCategory.plants: _IconSpec(
    label: '草木',
    statuses: ['草', '木', '巨木', '苔', '実'],
    availableColors: {
      '#EE913B', '#E2AA3B', '#F2D04F', '#8DBF54', '#5EB165',
      '#3B8444', '#3D88D8', '#2D6CA8', '#AB68C6', '#6B3293',
      '#D13F73', '#E57399', '#AB9289', '#5C453E',
    },
  ),
  IconCategory.scenery: _IconSpec(
    label: '景色',
    statuses: ['山', '滝', '木道', '雪原', 'その他'],
    availableColors: {
      '#F0F0F0', '#8C8C8C', '#212121', '#E05353', '#EE913B',
      '#E2AA3B', '#F2D04F', '#8DBF54', '#5EB165', '#3B8444',
      '#2DB0C2', '#3D88D8', '#2D6CA8', '#AB68C6', '#6B3293',
      '#D13F73', '#E57399', '#AB9289', '#5C453E',
    },
  ),
  IconCategory.hut:    _IconSpec(label: '山小屋', statuses: ['有人', '無人']),
  IconCategory.water:  _IconSpec(label: '水場',   statuses: ['枯れ', '少ない', '水あり']),
  IconCategory.danger: _IconSpec(
    label: '危険情報',
    statuses: ['崩落', '通行不可', '通行注意', '野生動物', '雪崩', '雪庇'],
  ),
  IconCategory.other:  _IconSpec(label: 'その他'),
};

const _categoryIcons = <IconCategory, IconData>{
  IconCategory.flower:  Icons.local_florist,
  IconCategory.foliage: Icons.eco,
  IconCategory.plants:  Icons.grass,
  IconCategory.scenery: Icons.landscape,
  IconCategory.hut:     Icons.cottage,
  IconCategory.water:   Icons.water_drop,
  IconCategory.danger:  Icons.warning_amber,
  IconCategory.other:   Icons.more_horiz,
};

const _colonyCategories = {
  IconCategory.flower,
  IconCategory.foliage,
  IconCategory.plants,
};

Color _hexColor(String hex) => Color(int.parse('0xFF${hex.substring(1)}'));

Color _contrastColor(Color bg) =>
    bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

// ── メインシート ──────────────────────────────────────────────────────────────

class PostCreationSheet extends ConsumerStatefulWidget {
  const PostCreationSheet({super.key});
  @override
  ConsumerState<PostCreationSheet> createState() => _PostCreationSheetState();
}

class _PostCreationSheetState extends ConsumerState<PostCreationSheet> {
  Uint8List? _imageBytes;
  final _plantController = TextEditingController();
  final _locationController = TextEditingController();

  // カテゴリ列・状態列の統一サイズ
  static const double _colCatWidth  = 110;
  static const double _colStatWidth = 90;
  static const double _itemHeight   = 34;
  static const double _circleSize   = 30;

  @override
  void dispose() {
    _plantController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadBytes(XFile file) async {
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
  }

  bool _canSubmit(PostDraft draft) {
    if (draft.photoFile == null || !draft.hasLocation) return false;
    if (draft.iconCategory == null) return false;
    final spec = _iconSpecs[draft.iconCategory!]!;
    if (spec.statuses.isNotEmpty && draft.iconStatus == null) return false;
    if (spec.availableColors.isNotEmpty && draft.iconColor == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final draft    = ref.watch(postCreationProvider);
    final notifier = ref.read(postCreationProvider.notifier);

    ref.listen<PostDraft>(postCreationProvider, (prev, next) {
      if (prev?.photoFile?.path != next.photoFile?.path && next.photoFile != null) {
        _loadBytes(next.photoFile!);
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final spec = draft.iconCategory == null ? null : _iconSpecs[draft.iconCategory!];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
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
              // ドラッグハンドル
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('新規投稿', style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              const Divider(height: 1),

              // スクロールエリア
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── 写真 ──────────────────────────────────
                      _buildPhotoSection(context, draft, notifier),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ── カテゴリ / 状態 / 色（横並び3列）────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1列目: カテゴリ
                          _buildCategoryColumn(context, draft, notifier),

                          // 2列目: 状態（カテゴリ選択後に表示）
                          if (spec != null && spec.statuses.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildStatusColumn(context, draft, notifier, spec),
                          ],

                          // 3列目: 色（状態選択後に表示）
                          if (spec != null &&
                              spec.availableColors.isNotEmpty &&
                              draft.iconStatus != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildColorColumn(draft, notifier, spec),
                            ),
                          ],
                        ],
                      ),

                      // ── 群落トグル ────────────────────────────
                      if (draft.iconCategory != null &&
                          _colonyCategories.contains(draft.iconCategory)) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('群落（まとまって生えている）'),
                          subtitle: const Text('複数株が密集している場合にオン'),
                          value: draft.isColony,
                          onChanged: notifier.setColony,
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ── タグ（任意）──────────────────────────
                      Text('タグ（任意）', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 10),
                      _TagInput(
                        title: '植物名',
                        hint: 'カタカナまたは英語（例：ニッコウキスゲ）',
                        controller: _plantController,
                        tags: draft.plantTags,
                        onSubmit: notifier.addPlantTag,
                        onDelete: notifier.removePlantTag,
                      ),
                      const SizedBox(height: 16),
                      _TagInput(
                        title: '場所',
                        hint: '日本語または英語（例：立山）',
                        controller: _locationController,
                        tags: draft.locationTags,
                        onSubmit: notifier.addLocationTag,
                        onDelete: notifier.removeLocationTag,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // 投稿ボタン
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canSubmit(draft)
                        ? () async {
                            await notifier.submitPost();
                            notifier.reset();
                            if (context.mounted) Navigator.pop(context);
                          }
                        : null,
                    child: const Text('投稿する'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 写真セクション ────────────────────────────────────────────────────────────

  Widget _buildPhotoSection(
    BuildContext context, PostDraft draft, PostCreationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final ok = await notifier.pickPhoto();
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('位置情報または撮影日時のない写真は投稿できません')),
              );
            }
          },
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(draft.photoFile == null ? '写真を選択' : '写真を変更'),
        ),
        if (draft.photoFile != null) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左: 写真サムネイル（大きめ）
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : const ColoredBox(
                            color: Colors.black12,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 右: 撮影情報（コンパクト縦積み）
              SizedBox(width: 120, child: _InfoCard(draft: draft)),
            ],
          ),
          if (!draft.hasLocation) ...[
            const SizedBox(height: 8),
            Text(
              '位置情報または撮影日時が含まれていません',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
        ],
      ],
    );
  }

  // ── 1列目: カテゴリ（左端揃え・サイズ統一）──────────────────────────────────

  Widget _buildCategoryColumn(
    BuildContext context, PostDraft draft, PostCreationNotifier notifier,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hasSelection = draft.iconCategory != null;
    return SizedBox(
      width: _colCatWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: IconCategory.values.map((cat) {
          final spec     = _iconSpecs[cat]!;
          final selected = draft.iconCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Opacity(
              opacity: hasSelection && !selected ? 0.3 : 1.0,
              child: SizedBox(
                height: _itemHeight,
                child: _RowButton(
                  leading: Icon(_categoryIcons[cat]!, size: 14,
                    color: selected ? cs.onPrimaryContainer : cs.onSurface),
                  label: spec.label,
                  selected: selected,
                  selectedBg: cs.primaryContainer,
                  selectedBorder: cs.primary,
                  labelColor: selected ? cs.onPrimaryContainer : cs.onSurface,
                  onTap: () => notifier.selectCategory(cat),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 2列目: 状態（カテゴリ選択後に右に表示）──────────────────────────────────

  Widget _buildStatusColumn(
    BuildContext context, PostDraft draft, PostCreationNotifier notifier, _IconSpec spec,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hasSelection = draft.iconStatus != null;
    return SizedBox(
      width: _colStatWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spec.statuses.map((s) {
          final selected = draft.iconStatus == s;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Opacity(
              opacity: hasSelection && !selected ? 0.3 : 1.0,
              child: SizedBox(
                height: _itemHeight,
                child: _RowButton(
                  label: s,
                  selected: selected,
                  selectedBg: cs.secondaryContainer,
                  selectedBorder: cs.secondary,
                  labelColor: selected ? cs.onSecondaryContainer : cs.onSurface,
                  onTap: () => notifier.selectStatus(s),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 3列目: 色（状態選択後に右に表示）────────────────────────────────────────

  Widget _buildColorColumn(
    PostDraft draft, PostCreationNotifier notifier, _IconSpec spec,
  ) {
    final hasSelection = draft.iconColor != null;
    final available = _colorPalette
        .where((c) => spec.availableColors.contains(c.hex))
        .toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: available.map((c) {
        final color    = _hexColor(c.hex);
        final selected = draft.iconColor == c.hex;
        return Tooltip(
          message: c.name,
          child: Opacity(
            opacity: hasSelection && !selected ? 0.3 : 1.0,
            child: GestureDetector(
              onTap: () => notifier.selectColor(c.hex),
              child: Container(
                width: _circleSize,
                height: _circleSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: Colors.black87, width: 2.5)
                      : Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: selected
                      ? [const BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2))]
                      : null,
                ),
                child: selected
                    ? Icon(Icons.check, size: 15, color: _contrastColor(color))
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 汎用行ボタン（左端揃え・全幅・固定高さ）──────────────────────────────────

class _RowButton extends StatelessWidget {
  const _RowButton({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedBorder,
    required this.labelColor,
    required this.onTap,
    this.leading,
  });
  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedBorder;
  final Color labelColor;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? selectedBorder : cs.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 5)],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: labelColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 撮影情報カード ────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.draft});
  final PostDraft draft;

  String get _shotAtText {
    final dt = draft.shotAt;
    if (dt == null) return '未取得';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final valueStyle = Theme.of(context).textTheme.bodySmall;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('緯度', style: labelStyle),
            Text(draft.latitude?.toStringAsFixed(5) ?? '未取得', style: valueStyle),
            const SizedBox(height: 8),
            Text('経度', style: labelStyle),
            Text(draft.longitude?.toStringAsFixed(5) ?? '未取得', style: valueStyle),
            const SizedBox(height: 8),
            Text('撮影日時', style: labelStyle),
            Text(_shotAtText, style: valueStyle),
          ],
        ),
      ),
    );
  }
}

// ── タグ入力 ──────────────────────────────────────────────────────────────────

class _TagInput extends StatelessWidget {
  const _TagInput({
    required this.title,
    required this.hint,
    required this.controller,
    required this.tags,
    required this.onSubmit,
    required this.onDelete,
  });
  final String title;
  final String hint;
  final TextEditingController controller;
  final List<String> tags;
  final void Function(String) onSubmit;
  final void Function(String) onDelete;

  void _submit() {
    final tag = controller.text.trim();
    if (tag.isEmpty) return;
    onSubmit(tag);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(hint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'タグを入力してEnter',
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _submit, child: const Text('追加')),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags
                .map((tag) => Chip(label: Text(tag), onDeleted: () => onDelete(tag)))
                .toList(),
          ),
        ],
      ],
    );
  }
}
