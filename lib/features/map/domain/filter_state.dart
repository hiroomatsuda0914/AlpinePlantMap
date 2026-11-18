import 'package:alpine_plant_map/features/map/domain/post.dart';

class FilterState {
  final IconCategory? selectedCategory;
  final Map<IconCategory, Set<String>> selectedSubcategories;
  final Set<String> selectedColors;
  final bool isColonyOnly;
  final Set<int> selectedYears;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  const FilterState({
    this.selectedCategory,
    this.selectedSubcategories = const {},
    this.selectedColors = const {},
    this.isColonyOnly = false,
    this.selectedYears = const {},
    required this.rangeStart,
    required this.rangeEnd,
  });

  factory FilterState.defaultState() {
    return FilterState(
      rangeStart: DateTime(2000, 1, 1),
      rangeEnd: DateTime(2000, 12, 31),
    );
  }

  FilterState copyWith({
    IconCategory? selectedCategory,
    bool clearCategory = false,
    Map<IconCategory, Set<String>>? selectedSubcategories,
    Set<String>? selectedColors,
    bool? isColonyOnly,
    Set<int>? selectedYears,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    return FilterState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSubcategories: selectedSubcategories ?? this.selectedSubcategories,
      selectedColors: selectedColors ?? this.selectedColors,
      isColonyOnly: isColonyOnly ?? this.isColonyOnly,
      selectedYears: selectedYears ?? this.selectedYears,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
    );
  }
}
