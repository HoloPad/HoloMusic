class PaginatedResponse<T> {
  T result;
  int currentPage;
  bool hasNext;

  PaginatedResponse(this.result, {this.currentPage = 0, this.hasNext = false});

  factory PaginatedResponse.fromJson(T result, Map<String, dynamic> json) {
    final hasNext = json['hasNextPage'] as bool;
    final currentPage = json['currentPage'] as int;
    return PaginatedResponse(result, currentPage: currentPage, hasNext: hasNext);
  }

  @override
  String toString() {
    return "currentPage: $currentPage - hasNext: $hasNext - Result: $result";
  }
}
