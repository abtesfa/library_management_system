
package com.library.library_backend.repository;

import com.library.library_backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReservationRepository
        extends JpaRepository<Reservation, Integer> {

    // Get all reservations belonging to one student.
    @Query(value = """
        SELECT
            r.Reservation_ID AS reservationId,
            r.Book_ID AS bookId,
            b.Title AS bookTitle,
            a.Author_Name AS author,
            r.Reservation_Date AS reservedDate,
            r.Hold_Until AS holdUntil,
            r.Pickup_Location AS pickupLocation,
            r.Status AS status,
            r.Queue_Position AS queuePosition
        FROM reservations r
        JOIN book b ON r.Book_ID = b.Book_ID
        LEFT JOIN author a ON b.Author_ID = a.Author_ID
        WHERE r.User_ID = :userId
        ORDER BY r.Reservation_Date DESC
        """, nativeQuery = true)
    List<Object[]> findReservationsByUserId(
            @Param("userId") Integer userId
    );

    // Check whether the student already has an active reservation.
    @Query(value = """
        SELECT COUNT(*)
        FROM reservations
        WHERE User_ID = :userId
        AND Book_ID = :bookId
        AND Status IN ('WAITING', 'READY_FOR_PICKUP')
        """, nativeQuery = true)
    long countActiveReservation(
            @Param("userId") Integer userId,
            @Param("bookId") Integer bookId
    );

    // Calculate the next waiting queue position for a book.
    @Query(value = """
        SELECT COALESCE(MAX(Queue_Position), 0) + 1
        FROM reservations
        WHERE Book_ID = :bookId
        AND Status = 'WAITING'
        """, nativeQuery = true)
    int getNextQueuePosition(
            @Param("bookId") Integer bookId
    );
}
