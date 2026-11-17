import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';
import 'package:alpine_plant_map/features/map/domain/filter_state.dart';

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => FilterState.defaultState();

  void toggleCategory(IconCategory category) {
    final current = Set<IconCategory>.from(state.selectedCategories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    // 小項目・色はリセットしない（カテゴリ別に保持）
    state = state.copyWith(selectedCategories: current);
  }

  /// カテゴリ別に小項目を独立管理する
  void toggleSubcategory(IconCategory category, String subcategory) {
    // Map を深くコピー
    final current = {
      for (final e in state.selectedSubcategories.entries)
        e.key: Set<String>.from(e.value),
    };
    final subs = current[category] ?? <String>{};
    if (subs.contains(subcategory)) {
      subs.remove(subcategory);
    } else {
      subs.add(subcategory);
    }
    if (subs.isEmpty) {
      current.remove(category);
    } else {
      current[category] = subs;
    }
    state = state.copyWith(selectedSubcategories: current);
  }

  void toggleColor(String hexColor) {
    final current = Set<String>.from(state.selectedColors);
    if (current.contains(hexColor)) {
      current.remove(hexColor);
    } else {
      current.add(hexColor);
    }
    state = state.copyWith(selectedColors: current);
  }

  void setColonyOnly(bool value){
    state = state.copyWith(isColonyOnly: value);

  }

  void toggleYear(int year){
    final current = Set<int>.from(state.selectedYears);
    if (current.contains(year)) {
      current.remove(year);
    } else {
      current.add(year);
    }
    state = state.copyWith(selectedYears: current);
  }

  void setDateRange(DateTime start, DateTime end){
    state = state.copyWith(rangeStart: start, rangeEnd: end);
  }

  void reset() {
    state = FilterState.defaultState();
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(
  FilterNotifier.new,
);