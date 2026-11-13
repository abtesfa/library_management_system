
package com.library.library_backend.repository;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

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
}
