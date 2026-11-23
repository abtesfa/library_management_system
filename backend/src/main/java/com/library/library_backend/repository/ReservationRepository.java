
package com.library.library_backend.repository;

import com.library.library_backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository
        extends JpaRepository<Reservation, Integer> {

    @Query(value = """
        SELECT
            r.Reservation_ID,
            r.Book_ID,
            b.Title,
            a.Author_Name,
            r.Reservation_Date,
            r.Hold_Until,
            r.Pickup_Location,
            r.Status,
            r.Queue_Position,
            r.Estimated_Available_At
        FROM reservations r
        JOIN book b ON r.Book_ID = b.Book_ID
        LEFT JOIN author a ON b.Author_ID = a.Author_ID
        WHERE r.User_ID = :userId
        ORDER BY r.Reservation_Date DESC
        """, nativeQuery = true)
    List<Object[]> findReservationsByUserId(
            @Param("userId") Integer userId
    );

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.bookId = :bookId
        AND r.status IN ('WAITING', 'READY_FOR_PICKUP')
        ORDER BY r.reservationDate ASC, r.reservationId ASC
        """)
    List<Reservation> findActiveQueue(
            @Param("bookId") Integer bookId
    );

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.bookId = :bookId
        AND r.status = 'WAITING'
        ORDER BY r.reservationDate ASC, r.reservationId ASC
        """)
    List<Reservation> findWaitingQueue(
            @Param("bookId") Integer bookId
    );
List<Reservation> findAllByBookId(Integer bookId);
    @Query("""
        SELECT COUNT(r) FROM Reservation r
        WHERE r.userId = :userId
        AND r.status IN ('WAITING', 'READY_FOR_PICKUP')
        """)
    long countActiveByUserId(
            @Param("userId") Integer userId
    );

    @Query("""
        SELECT COUNT(r) FROM Reservation r
        WHERE r.userId = :userId
        AND r.bookId = :bookId
        AND r.status IN ('WAITING', 'READY_FOR_PICKUP')
        """)
    long countActiveReservation(
            @Param("userId") Integer userId,
            @Param("bookId") Integer bookId
    );

    @Query("""
        SELECT COUNT(r) FROM Reservation r
        WHERE r.bookId = :bookId
        AND r.status IN ('WAITING', 'READY_FOR_PICKUP')
        """)
    long countActiveByBookId(
            @Param("bookId") Integer bookId
    );

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.status = 'READY_FOR_PICKUP'
        AND r.holdUntil IS NOT NULL
        AND r.holdUntil <= :cutoff
        """)
    List<Reservation> findExpiredReadyReservations(
            @Param("cutoff") LocalDateTime cutoff
    );

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.bookId = :bookId
        AND r.status = 'READY_FOR_PICKUP'
        AND r.holdUntil IS NOT NULL
        AND r.holdUntil <= :cutoff
        """)
    List<Reservation> findExpiredReadyReservationsByBookId(
            @Param("bookId") Integer bookId,
            @Param("cutoff") LocalDateTime cutoff);

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.userId = :userId
        AND r.bookId = :bookId
        AND r.status IN ('WAITING', 'READY_FOR_PICKUP')
        ORDER BY r.reservationDate ASC, r.reservationId ASC
        """)
    Optional<Reservation> findActiveReservation(
            @Param("userId") Integer userId,
            @Param("bookId") Integer bookId
    );

    @Query("""
        SELECT r FROM Reservation r
        WHERE r.allocatedCopyId = :copyId
        AND r.status = 'READY_FOR_PICKUP'
        """)
    Optional<Reservation> findReadyReservationByCopyId(
            @Param("copyId") Integer copyId
    );
}
