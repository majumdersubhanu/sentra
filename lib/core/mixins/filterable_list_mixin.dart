import 'package:flutter/material.dart';

/// Mixin that provides shared search query + enum-based filter state
/// and a generic filtering method for all list screens.
///
/// The constraint uses `StatefulWidget` base, so it works with both
/// `State<T>` and `ConsumerState<T>` (which extends `State<T>`).
mixin FilterableListMixin<T, S extends Enum> {
  String searchQuery = '';
  S? statusFilter;

  /// Override to define how search matches items.
  bool searchMatch(T item, String query);

  /// Override to extract the status enum from an item (for filter chips).
  Enum? getItemStatus(T item);

  /// Must be implemented — delegates to the host's setState.
  void setFilterState(VoidCallback fn);

  void updateSearch(String query) {
    setFilterState(() => searchQuery = query);
  }

  void updateFilter(S? filter) {
    setFilterState(() => statusFilter = filter);
  }

  /// Applies both search and status filters to the list.
  List<T> applyFilters(List<T> items) {
    var filtered = items;

    if (statusFilter != null) {
      filtered = filtered
          .where((item) => getItemStatus(item) == statusFilter)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) => searchMatch(item, query)).toList();
    }

    return filtered;
  }
}
