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
    return Container(
      width: 260,
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'フィルタ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(filterProvider.notifier).reset(),
                  child: const Text('リセット'),
                ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('群生地のみ'),
            value: filter.isColonyOnly,
            onChanged: (value) =>
                ref.read(filterProvider.notifier).setColonyOnly(value),
            dense: true,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'カテゴリ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ...IconCategory.values.map((category) {
                  final selected = filter.selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(_categoryLabel(category)),
                    selected: selected,
                    onSelected: (_) => ref
                        .read(filterProvider.notifier)
                        .toggleCategory(category),
                  );
                }).toList(),
              ],
            ),
          ),
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
              children: [
                ...List.generate(5, (i) => DateTime.now().year - i).map((year) {
                  final selected = filter.selectedYears.contains(year);
                  return FilterChip(
                    label: Text('$year'),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).toggleYear(year),
                  );
                }).toList(),
              ],
            ),
          ),
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
                    ref
                        .read(filterProvider.notifier)
                        .setDateRange(
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
}

String _categoryLabel(IconCategory category) {
  const labels = {
    IconCategory.flower: '花',
    IconCategory.foliage: '紅葉・枯れ',
    IconCategory.berry: '実',
    IconCategory.snow: '雪',
    IconCategory.plant: '植物',
    IconCategory.mushroom: 'きのこ',
    IconCategory.mountain: '山・景色',
    IconCategory.hut: '山小屋',
    IconCategory.water: '水場',
    IconCategory.trailDamage: '崩落・通行止め',
    IconCategory.other: 'その他',
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
