package com.library.library_backend.Service;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.NotificationRepository;

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

    // Create a Due Soon or Overdue notification for a borrowing
    @Transactional
    public Notification createBorrowingNotification(
            Integer borrowingId,
            String studentName,
            String studentId,
            String bookTitle,
            LocalDate dueDate,
            NotificationType type) {

        if (type != NotificationType.DUE_SOON
                && type != NotificationType.OVERDUE) {
            throw new IllegalArgumentException(
                    "Invalid borrowing notification type.");
        }

        // Do not create duplicates
        if (notificationRepository
                .existsByBorrowingIdAndNotificationType(
                        borrowingId, type)) {
            return null;
        }

        Notification notification = new Notification();

        notification.setBorrowingId(borrowingId);
        notification.setRecipientType("LIBRARIAN");
        notification.setNotificationType(type);
        notification.setIsRead(false);

        if (type == NotificationType.DUE_SOON) {
            notification.setTitle("Book Due Soon");

            notification.setMessage(
                    studentName + " (" + studentId + ") has borrowed \""
                            + bookTitle + "\", which is due on " + dueDate + ".");

            notification.setDetails(
                    "Borrowing ID: " + borrowingId
                            + ". Student ID: " + studentId
                            + ". Due date: " + dueDate);
        } else {
            notification.setTitle("Overdue Book");

            notification.setMessage(
                    studentName + " (" + studentId + ") has not returned \""
                            + bookTitle + "\". It was due on " + dueDate + ".");

            notification.setDetails(
                    "Borrowing ID: " + borrowingId
                            + ". Student ID: " + studentId
                            + ". Due date: " + dueDate);
        }

        return notificationRepository.save(notification);
    }

    // Delete all notifications associated with a borrowing
    @Transactional
    public void deleteByBorrowingId(Integer borrowingId) {
        notificationRepository.deleteByBorrowingId(borrowingId);
    }

    // Delete one notification category associated with a borrowing
    @Transactional
    public void deleteByBorrowingIdAndType(
            Integer borrowingId,
            NotificationType type) {

        notificationRepository.deleteByBorrowingIdAndNotificationType(
                borrowingId, type);
    }

    // Automatically create a librarian notification for a reservation
    public Notification createReservationNotification(
            Integer reservationId,
            String studentName,
            String bookTitle) {

        Notification notification = new Notification();

        notification.setTitle("New Book Reservation");

        notification.setMessage(
                studentName + " has reserved \"" + bookTitle + "\".");

        notification.setDetails(
                "A student has submitted a new book reservation. "
                        + "Reservation ID: " + reservationId);

        notification.setNotificationType(NotificationType.RESERVATION);
        notification.setRecipientType("LIBRARIAN");
        notification.setReservationId(reservationId);
        notification.setIsRead(false);

        return notificationRepository.save(notification);
    }

    // Remove every notification linked to a reservation
    // (used when the reservation is cancelled)
    @Transactional
    public void deleteByReservationId(Integer reservationId) {

        notificationRepository.deleteAll(
                notificationRepository.findByReservationId(reservationId));
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
    public List<Notification> getStudentNotifications(Integer userId) {
    return notificationRepository.findStudentNotifications(userId);
}

public List<Notification> getUnreadStudentNotifications(Integer userId) {
    return notificationRepository.findUnreadStudentNotifications(userId);
}

@Transactional
public Notification createReservationReadyNotification(
        Integer reservationId,
        Integer userId,
        String bookTitle,
        LocalDateTime holdUntil) {

    Notification notification = new Notification();

    notification.setTitle("Reserved Book Ready for Pickup");

    notification.setMessage(
            "\"" + bookTitle + "\" is now ready for collection. "
            + "Please collect it before " + holdUntil + "."
    );

    notification.setDetails(
            "Reservation ID: " + reservationId
            + ". Your pickup hold expires at " + holdUntil + "."
    );

    notification.setNotificationType(NotificationType.RESERVATION);
    notification.setRecipientType("STUDENT");
    notification.setRecipientId(userId);
    notification.setReservationId(reservationId);
    notification.setIsRead(false);

    return notificationRepository.save(notification);
}
}