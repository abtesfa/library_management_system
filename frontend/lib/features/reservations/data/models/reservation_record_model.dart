import '../../domain/entities/reservation_record.dart';

/// JSON-aware version of [ReservationRecord] used by the data layer.
class ReservationRecordModel extends ReservationRecord {
  ReservationRecordModel({
    required super.id,
    required super.bookId,
    required super.bookTitle,
    required super.author,
    required super.reservedDate,
    super.holdUntil,
    super.pickupLocation,
    required super.status,
    required super.queuePosition,
  });

  factory ReservationRecordModel.fromJson(Map<String, dynamic> json) {
    return ReservationRecordModel(
      id: json['reservationId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      bookTitle: json['bookTitle']?.toString() ?? 'Unknown Book',
      author: json['author']?.toString() ?? 'Unknown Author',
      reservedDate: json['reservedDate']?.toString() ?? '',
      holdUntil: json['holdUntil']?.toString(),
      pickupLocation: json['pickupLocation']?.toString(),
      status: json['status']?.toString() ?? 'WAITING',
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 1,
    );
  }
}
