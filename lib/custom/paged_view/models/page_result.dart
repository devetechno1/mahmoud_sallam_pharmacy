// lib/custom/paged_view/models/page_result.dart
// Null-safe paging result model (reusable).
class PageResult<T> {
  final List<T> data;
  final bool hasMore;
  const PageResult({required this.data, required this.hasMore});
}
