
package com.library.library_backend.Service;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.NotificationRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(
            NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    // Get all notifications
    public List<Notification> getAllNotifications() {
        return notificationRepository.findAllByOrderByCreatedAtDesc();
    }

    // Get notifications by category
    public List<Notification> getNotificationsByType(
            NotificationType type) {
        return notificationRepository
                .findByNotificationTypeOrderByCreatedAtDesc(type);
    }

    // Get unread notifications
    public List<Notification> getUnreadNotifications() {
        return notificationRepository
                .findByIsReadFalseOrderByCreatedAtDesc();
    }

    // Get librarian notifications
    public List<Notification> getLibrarianNotifications() {
        return notificationRepository.findLibrarianNotifications();
    }

    // Get unread librarian notifications
    public List<Notification> getUnreadLibrarianNotifications() {
        return notificationRepository
                .findUnreadLibrarianNotifications();
    }

    // Create a notification
    public Notification createNotification(Notification notification) {

        if (notification.getTitle() == null
                || notification.getTitle().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Notification title is required");
        }

        if (notification.getMessage() == null
                || notification.getMessage().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Notification message is required");
        }

        if (notification.getNotificationType() == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Notification type is required");
        }

        notification.setIsRead(false);

        return notificationRepository.save(notification);
    }

    // Automatically create a librarian notification for a reservation
    public Notification createReservationNotification(
            Integer reservationId,
            String studentName,
            String bookTitle) {

        Notification notification = new Notification();

        notification.setTitle("New Book Reservation");

        notification.setMessage(
                studentName + " has reserved \"" + bookTitle + "\"."
        );

        notification.setDetails(
                "A student has submitted a new book reservation. "
                + "Reservation ID: " + reservationId
        );

        notification.setNotificationType(NotificationType.RESERVATION);
        notification.setRecipientType("LIBRARIAN");
        notification.setReservationId(reservationId);
        notification.setIsRead(false);

        return notificationRepository.save(notification);
    }

    // Mark a notification as read
    @Transactional
    public Notification markAsRead(Integer id) {

        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Notification not found"));

        notification.setIsRead(true);

        return notificationRepository.save(notification);
    }

    // Delete a notification
    public void deleteNotification(Integer id) {

        if (!notificationRepository.existsById(id)) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Notification not found");
        }

        notificationRepository.deleteById(id);
    }
}
