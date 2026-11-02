class InventorySummary {
  final int totalBooks;
  final int totalCopies;
  final int availableCopies;
  final int onLoanCopies;
  final int reservedCopies;

  InventorySummary({
    required this.totalBooks,
    required this.totalCopies,
    required this.availableCopies,
    required this.onLoanCopies,
    required this.reservedCopies,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalBooks: json['totalBooks'] ?? 0,
      totalCopies: json['totalCopies'] ?? 0,
      availableCopies: json['availableCopies'] ?? 0,
      onLoanCopies: json['onLoanCopies'] ?? 0,
      reservedCopies: json['reservedCopies'] ?? 0,
    );
  }

  factory InventorySummary.empty() {
    return InventorySummary(
      totalBooks: 0,
      totalCopies: 0,
      availableCopies: 0,
      onLoanCopies: 0,
      reservedCopies: 0,
    );
  }
}
