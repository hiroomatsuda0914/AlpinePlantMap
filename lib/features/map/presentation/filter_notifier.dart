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

  }

  void toggleYear(int year){

  }

  void setDateRange(DateTime start, DateTime end){

  }

  void rest() {

  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(
  FilterNotifier.new,
);