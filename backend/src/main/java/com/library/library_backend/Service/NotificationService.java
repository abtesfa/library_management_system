package com.library.library_backend.Service;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.ArrayList;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.NotificationRepository;

@Service
public class NotificationService {

    private static final int DUE_SOON_DAYS = 1;

    private final NotificationRepository notificationRepository;
    private final BorrowingRepository borrowingRepository;

    public NotificationService(
            NotificationRepository notificationRepository,
            BorrowingRepository borrowingRepository) {
        this.notificationRepository = notificationRepository;
        this.borrowingRepository = borrowingRepository;
    }

    // Get all notifications
    public List<Notification> getAllNotifications() {
        return notificationRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Notification> getStudentNotifications(Integer userId) {
        return notificationRepository.findByRecipientTypeAndRecipientIdOrderByCreatedAtDesc("STUDENT", userId);
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
    @Transactional
    public List<Notification> getLibrarianNotifications() {
        synchronizeBorrowingNotifications();
        return filterLibrarianAnnouncements(notificationRepository.findLibrarianNotifications(), null);
    }

    // Get unread librarian notifications
    @Transactional
    public List<Notification> getUnreadLibrarianNotifications() {
        synchronizeBorrowingNotifications();
        return filterLibrarianAnnouncements(notificationRepository.findUnreadLibrarianNotifications(), null);
    }


    @Transactional
    public List<Notification> getLibrarianNotifications(String position) {
        synchronizeBorrowingNotifications();
        return filterLibrarianAnnouncements(notificationRepository.findLibrarianNotifications(), position);
    }

    @Transactional
    public List<Notification> getUnreadLibrarianNotifications(String position) {
        synchronizeBorrowingNotifications();
        return filterLibrarianAnnouncements(notificationRepository.findUnreadLibrarianNotifications(), position);
    }

    private List<Notification> filterLibrarianAnnouncements(List<Notification> rows, String position) {
        LocalDate today = LocalDate.now();
        return rows.stream().filter(n -> {
            if (n.getNotificationType() != NotificationType.ANNOUNCEMENT) return true;
            if (Boolean.TRUE.equals(n.getArchived())) return false;
            if (n.getValidFrom() != null && n.getValidFrom().isAfter(today)) return false;
            if (n.getValidUntil() != null && n.getValidUntil().isBefore(today)) return false;
            if ("LIBRARIAN_POSITIONS".equals(n.getRecipientType())) {
                return position != null && n.getAudiencePositions() != null
                        && List.of(n.getAudiencePositions().split(",")).contains(position);
            }
            return true;
        }).toList();
    }

    private void synchronizeBorrowingNotifications() {
        Map<LoanNotificationKey, Notification> existing = new HashMap<>();
        for (Notification notification :
                notificationRepository.findByBorrowingIdIsNotNull()) {
            existing.put(
                    new LoanNotificationKey(
                            notification.getBorrowingId(),
                            notification.getNotificationType()),
                    notification);
        }

        Set<LoanNotificationKey> current = new HashSet<>();
        LocalDate today = LocalDate.now();

        for (Object[] row :
                borrowingRepository.findActiveBorrowingsForNotifications()) {
            Integer borrowingId = toInteger(row[0]);
            LocalDate dueDate = toLocalDate(row[1]);
            if (borrowingId == null || dueDate == null) {
                continue;
            }

            NotificationType type = notificationTypeFor(dueDate, today);
            if (type == null) {
                continue;
            }

            LoanNotificationKey key = new LoanNotificationKey(borrowingId, type);
            current.add(key);

            String studentName = toStringValue(row[2], "A student");
            String studentId = toStringValue(row[3], "Unknown");
            String bookTitle = toStringValue(row[4], "a borrowed book");
            Notification notification = existing.get(key);
            boolean isNew = notification == null;
            if (notification == null) {
                notification = new Notification();
                notification.setBorrowingId(borrowingId);
                notification.setNotificationType(type);
                notification.setRecipientType("LIBRARIAN");
                notification.setIsRead(false);
            }

            String date = dueDate.toString();
            String title =
                    type == NotificationType.OVERDUE
                            ? "Book is Overdue"
                            : "Book Due Soon";
            String message =
                    "\"" + bookTitle + "\" borrowed by " + studentName
                            + " (" + studentId + ") "
                            + (type == NotificationType.OVERDUE
                                    ? "is overdue."
                                    : "is due on " + date + ".");
            String details =
                    "Borrowing ID: " + borrowingId + " | Due date: " + date;
            boolean changed = isNew
                    || !Objects.equals(notification.getTitle(), title)
                    || !Objects.equals(notification.getMessage(), message)
                    || !Objects.equals(notification.getDetails(), details);
            notification.setTitle(title);
            notification.setMessage(message);
            notification.setDetails(details);

            if (changed) {
                notificationRepository.save(notification);
            }
        }

        List<Notification> stale = existing.entrySet().stream()
                .filter(entry -> !current.contains(entry.getKey()))
                .map(Map.Entry::getValue)
                .toList();
        if (!stale.isEmpty()) {
            notificationRepository.deleteAll(stale);
        }
    }

    private NotificationType notificationTypeFor(
            LocalDate dueDate,
            LocalDate today) {
        if (dueDate.isBefore(today)) {
            return NotificationType.OVERDUE;
        }
        if (!dueDate.isAfter(today.plusDays(DUE_SOON_DAYS))) {
            return NotificationType.DUE_SOON;
        }
        return null;
    }

    private Integer toInteger(Object value) {
        return value instanceof Number number ? number.intValue() : null;
    }

    private LocalDate toLocalDate(Object value) {
        if (value instanceof LocalDate date) {
            return date;
        }
        if (value instanceof Date date) {
            return date.toLocalDate();
        }
        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate();
        }
        if (value instanceof LocalDateTime dateTime) {
            return dateTime.toLocalDate();
        }
        if (value instanceof String text) {
            return LocalDate.parse(text);
        }
        return null;
    }

    private String toStringValue(Object value, String fallback) {
        return value == null ? fallback : value.toString();
    }

    private record LoanNotificationKey(
            Integer borrowingId,
            NotificationType type) {
    }

    // Structured announcement lifecycle

    @Transactional
    public Notification createAnnouncement(String title, String message, String priority,
            List<String> positions, LocalDate validFrom, LocalDate validUntil) {
        if (title == null || title.isBlank() || message == null || message.isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Announcement title and message are required.");
        if (!List.of("NORMAL", "IMPORTANT", "URGENT").contains(priority == null ? "NORMAL" : priority.toUpperCase()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Priority must be NORMAL, IMPORTANT, or URGENT.");
        if (validFrom != null && validUntil != null && validUntil.isBefore(validFrom))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Valid-until date cannot be before valid-from date.");
        Notification n = new Notification();
        n.setTitle(title.trim()); n.setMessage(message.trim());
        n.setNotificationType(NotificationType.ANNOUNCEMENT);
        n.setRecipientType(positions == null || positions.isEmpty() ? "LIBRARIAN" : "LIBRARIAN_POSITIONS");
        n.setAudiencePositions(positions == null || positions.isEmpty() ? null : String.join(",", positions));
        n.setAnnouncementPriority(priority == null ? "NORMAL" : priority.toUpperCase());
        n.setValidFrom(validFrom); n.setValidUntil(validUntil); n.setArchived(false); n.setIsRead(false);
        return notificationRepository.save(n);
    }

    @Transactional
    public List<Notification> getVisibleAnnouncements(String position) {
        LocalDate today = LocalDate.now();
        return notificationRepository.findAllByNotificationTypeOrderByCreatedAtDesc(NotificationType.ANNOUNCEMENT)
                .stream().filter(n -> !Boolean.TRUE.equals(n.getArchived()))
                .filter(n -> n.getValidFrom() == null || !n.getValidFrom().isAfter(today))
                .filter(n -> n.getValidUntil() == null || !n.getValidUntil().isBefore(today))
                .filter(n -> !"LIBRARIAN_POSITIONS".equals(n.getRecipientType()) || (position != null && n.getAudiencePositions() != null && List.of(n.getAudiencePositions().split(",")).contains(position)))
                .toList();
    }

    @Transactional
    public Notification archiveAnnouncement(Integer id) {
        Notification n = notificationRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Announcement not found."));
        if (n.getNotificationType() != NotificationType.ANNOUNCEMENT) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Only announcements can be archived.");
        n.setArchived(true); return notificationRepository.save(n);
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

    public Notification createStudentReservationReadyNotification(Integer userId, Integer reservationId, String bookTitle) {
        Notification n = new Notification();
        n.setTitle("Your reservation is ready");
        n.setMessage("A copy of \"" + bookTitle + "\" is ready for collection.");
        n.setDetails("Collect it before the hold deadline shown in My Reservations.");
        n.setNotificationType(NotificationType.RESERVATION);
        n.setRecipientType("STUDENT");
        n.setRecipientId(userId);
        n.setReservationId(reservationId);
        n.setIsRead(false);
        return notificationRepository.save(n);
    }

    // Remove every notification linked to a reservation
    // (used when the reservation is cancelled)
    @Transactional
    public void deleteByReservationId(Integer reservationId) {

        notificationRepository.deleteAll(
                notificationRepository.findByReservationId(reservationId)
        );
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