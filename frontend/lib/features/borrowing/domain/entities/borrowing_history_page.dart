import 'borrow_record.dart';

class BorrowingHistoryPage {
  final List<BorrowRecord> records;
  final int page;
  final int pageSize;
  final bool hasNext;

  const BorrowingHistoryPage({
    required this.records,
    required this.page,
    required this.pageSize,
    required this.hasNext,
  });
}