import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/presentation/filter_notifier.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';

class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key});

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _isExpanded ? 260 : 0,
          child: _isExpanded ? _PanelContent() : const SizedBox.shrink(),
        ),
        _ToggleButton(
          isExpanded: _isExpanded,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isExpanded ? Icons.chevron_left : Icons.chevron_right,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _PanelContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 260,
      color: cs.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // ── ヘッダー ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  const Text('フィルタ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref.read(filterProvider.notifier).reset(),
                    child: const Text('リセット'),
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── 群生地スイッチ ────────────────────────────────────────
            SwitchListTile(
              title: const Text('群生地のみ'),
              value: filter.isColonyOnly,
              onChanged: (v) =>
                  ref.read(filterProvider.notifier).setColonyOnly(v),
              dense: true,
            ),

            // ── 大項目 ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('大項目', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: IconCategory.values.map((cat) {
                  final isSelected = filter.selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(_categoryLabel(cat)),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).toggleCategory(cat),
                  );
                }).toList(),
              ),
            ),

            // ── 小項目（選択中の大項目ごとにグループ表示） ───────────────
            ..._buildSubcategorySection(filter, cs, ref),

            // ── 色（常時表示） ────────────────────────────────────────
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('色', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filterColorPalette.map((c) {
                  final hex      = c.$1;
                  final name     = c.$2;
                  final color    = _hexToColor(hex);
                  final selected = filter.selectedColors.contains(hex);
                  return Tooltip(
                    message: name,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(filterProvider.notifier).toggleColor(hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.black87, width: 2.5)
                              : Border.all(
                                  color: Colors.grey.shade300, width: 1),
                          boxShadow: selected
                              ? [const BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black26,
                                  offset: Offset(0, 2))]
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check,
                                size: 16,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black87
                                    : Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── 年 ───────────────────────────────────────────────────
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('年', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(5, (i) => DateTime.now().year - i)
                    .map((year) {
                  final selected = filter.selectedYears.contains(year);
                  return FilterChip(
                    label: Text('$year'),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).toggleYear(year),
                  );
                }).toList(),
              ),
            ),

            // ── 時期 ─────────────────────────────────────────────────
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('時期', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    '${_formatMmDd(filter.rangeStart)} 〜 ${_formatMmDd(filter.rangeEnd)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  RangeSlider(
                    min: 1,
                    max: 366,
                    values: RangeValues(
                      _dateToDay(filter.rangeStart).toDouble(),
                      _dateToDay(filter.rangeEnd).toDouble(),
                    ),
                    onChanged: (values) {
                      ref.read(filterProvider.notifier).setDateRange(
                        _dayToDate(values.start.round()),
                        _dayToDate(values.end.round()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 選択中の大項目ごとに小項目チップをグループ表示するウィジェットリストを返す
  List<Widget> _buildSubcategorySection(
    FilterState filter, ColorScheme cs, WidgetRef ref,
  ) {
    if (filter.selectedCategories.isEmpty) return [];

    final result = <Widget>[
      const Divider(),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('小項目', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    ];

    for (final cat in filter.selectedCategories) {
      final subs = _categoryStatuses[cat] ?? const <String>[];
      if (subs.isEmpty) continue;

      final selectedSubs =
          filter.selectedSubcategories[cat] ?? const <String>{};

      // 大項目名をグループ見出しとして表示（左端のカラーバー付き）
      result.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _categoryLabel(cat),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ));

      result.add(Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: subs.map((sub) {
            final subSelected = selectedSubs.contains(sub);
            return FilterChip(
              label: Text(sub),
              selected: subSelected,
              onSelected: (_) => ref
                  .read(filterProvider.notifier)
                  .toggleSubcategory(cat, sub),
            );
          }).toList(),
        ),
      ));
    }

    return result;
  }
}

String _categoryLabel(IconCategory category) {
  const labels = {
    IconCategory.flower:     '花',
    IconCategory.foliage:    '紅葉',
    IconCategory.vegetation: '草木',
    IconCategory.scenery:    '景色',
    IconCategory.hut:        '山小屋',
    IconCategory.food:       '食べ物',
    IconCategory.water:      '水場',
    IconCategory.danger:     '危険情報',
    IconCategory.wildlife:   '野生動物',
    IconCategory.other:      'その他',
  };
  return labels[category] ?? category.name;
}

int _dateToDay(DateTime date) {
  return DateTime(
        date.year,
        date.month,
        date.day,
      ).difference(DateTime(date.year, 1, 1)).inDays +
      1;
}

DateTime _dayToDate(int day) {
  return DateTime(2000, 1, 1).add(Duration(days: day - 1));
}

String _formatMmDd(DateTime date) {
  return '${date.month}/${date.day}';
}

// ── 小項目・色フィルタ用ヘルパー ──────────────────────────────────────────────

Color _hexToColor(String hex) => Color(int.parse('0xFF${hex.substring(1)}'));


const _filterColorPalette = <(String, String)>[
  ('#E05353', '赤'),
  ('#EE913B', 'オレンジ'),
  ('#F2D04F', '黄色'),
  ('#5EB165', '緑'),
  ('#2DB0C2', '水色'),
  ('#3D88D8', '青'),
  ('#6B3293', '紫'),
  ('#5C453E', '茶色'),
  ('#F0F0F0', '白'),
  ('#212121', '黒'),
  ('#8C8C8C', 'その他'),
];

const _categoryStatuses = <IconCategory, List<String>>{
  IconCategory.flower:     ['つぼみ', '五分咲き', '満開', '散り始め', '終り'],
  IconCategory.foliage:    ['序盤', '8割', '最盛期', '終り'],
  IconCategory.vegetation: ['草', '木', '巨木', '苔', '実'],
  IconCategory.scenery:    ['山', '滝', '木道', '雪原', '雲', '空', '夜空', 'その他'],
  IconCategory.hut:        ['有人営業', '無人利用可', '利用不可', 'その他'],
  IconCategory.food:       ['山小屋グルメ', '自炊', 'その他'],
  IconCategory.water:      ['枯れ', '少ない', '水あり'],
  IconCategory.danger:     ['崩落', '通行不可', '通行注意', '雪渓'],
  IconCategory.wildlife:   ['サル', 'シカ', 'クマ', 'イノシシ', 'カモシカ', 'ライチョウ', 'ヘビ', 'タヌキ', 'キツネ', 'その他'],
  IconCategory.other:      [],
};
