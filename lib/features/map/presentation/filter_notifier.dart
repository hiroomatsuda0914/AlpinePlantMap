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
    state = state.copyWith(selectedCategories: current);
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