import 'package:alpine_plant_map/features/map/domain/post.dart';

class FilterState{
  final Set<IconCategory> selectedCategories;
  final bool isColonyOnly;
  final Set<int> selectedYears;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  const FilterState({
    this.selectedCategories = const {},
    this.isColonyOnly = false,
    this.selectedYears = const {},
    required this.rangeStart,
    required this.rangeEnd,
  });

  factory FilterState.defaultState() {
    final today = DateTime.now();
    return FilterState(
      rangeStart: today.subtract(const Duration(days: 15)),
      rangeEnd: today.add(const Duration(days: 15)),
    );
  }

  FilterState copyWith({
    Set<IconCategory>? selectedCategories,
    bool? isColonyOnly,
    Set<int>? selectedYears,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    return FilterState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isColonyOnly: isColonyOnly ?? this.isColonyOnly,
      selectedYears: selectedYears ?? this.selectedYears,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
    );
  }



}