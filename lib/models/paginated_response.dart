// lib/models/paginated_response.dart
class PaginatedResponse {
  final List<dynamic> items;
  final int currentPage;
  final int lastPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMorePages => currentPage < lastPage;

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      items: json['data'] ?? [],
      currentPage: json['meta']?['current_page'] ?? 1,
      lastPage: json['meta']?['last_page'] ?? 1,
    );
  }
}