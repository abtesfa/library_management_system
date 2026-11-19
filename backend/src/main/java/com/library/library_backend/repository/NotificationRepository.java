
package com.library.library_backend.repository;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface NotificationRepository
        extends JpaRepository<Notification, Integer> {

    // Retrieve all notifications, newest first
    List<Notification> findAllByOrderByCreatedAtDesc();

    // Retrieve notifications by category
    List<Notification> findByNotificationTypeOrderByCreatedAtDesc(
            NotificationType notificationType
    );

    // Retrieve unread notifications
    List<Notification> findByIsReadFalseOrderByCreatedAtDesc();

    // Retrieve notifications intended for librarians,
    // including general notifications
    @Query("""
        SELECT n FROM Notification n
        WHERE n.recipientType IN ('LIBRARIAN', 'ALL')
        ORDER BY n.createdAt DESC
        """)
    List<Notification> findLibrarianNotifications();

    // Retrieve unread notifications intended for librarians
    @Query("""
        SELECT n FROM Notification n
        WHERE n.recipientType IN ('LIBRARIAN', 'ALL')
        AND n.isRead = false
        ORDER BY n.createdAt DESC
        """)
    List<Notification> findUnreadLibrarianNotifications();

    // Find notifications related to a particular reservation
    List<Notification> findByReservationId(Integer reservationId);

    // Find notifications associated with a borrowing
List<Notification> findByBorrowingId(Integer borrowingId);

// Prevent duplicate notifications for the same borrowing and type
boolean existsByBorrowingIdAndNotificationType(
        Integer borrowingId,
        NotificationType notificationType
);

// Delete all notifications associated with a borrowing
@Modifying
@Query("""
    DELETE FROM Notification n
    WHERE n.borrowingId = :borrowingId
    """)
int deleteByBorrowingId(
        @Param("borrowingId") Integer borrowingId
);

// Delete one notification category for a borrowing
@Modifying
@Query("""
    DELETE FROM Notification n
    WHERE n.borrowingId = :borrowingId
    AND n.notificationType = :notificationType
    """)
int deleteByBorrowingIdAndNotificationType(
        @Param("borrowingId") Integer borrowingId,
        @Param("notificationType") NotificationType notificationType
);
    @Modifying
    @Query("DELETE FROM Notification notification "
            + "WHERE notification.reservationId IN :reservationIds")
    int deleteAllByReservationIdIn(
            @Param("reservationIds") Collection<Integer> reservationIds);
            @Query("""
    SELECT n FROM Notification n
    WHERE n.recipientType = 'STUDENT'
    AND n.recipientId = :userId
    ORDER BY n.createdAt DESC
    """)
List<Notification> findStudentNotifications(
        @Param("userId") Integer userId
);

@Query("""
    SELECT n FROM Notification n
    WHERE n.recipientType = 'STUDENT'
    AND n.recipientId = :userId
    AND n.isRead = false
    ORDER BY n.createdAt DESC
    """)
List<Notification> findUnreadStudentNotifications(
        @Param("userId") Integer userId
);
}
