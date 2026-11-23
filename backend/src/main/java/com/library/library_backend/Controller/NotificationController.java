
package com.library.library_backend.Controller;

import com.library.library_backend.Service.NotificationService;
import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(
            NotificationService notificationService) {
        this.notificationService = notificationService;
    }


    public record AnnouncementRequest(String title, String message, String priority,
            List<String> audiencePositions, LocalDate validFrom, LocalDate validUntil) {}

    @PostMapping("/announcements")
    public ResponseEntity<Notification> createAnnouncement(@RequestBody AnnouncementRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(notificationService.createAnnouncement(
                request.title(), request.message(), request.priority(), request.audiencePositions(), request.validFrom(), request.validUntil()));
    }

    @GetMapping("/announcements")
    public ResponseEntity<List<Notification>> getAnnouncements(@RequestParam(required = false) String position) {
        return ResponseEntity.ok(notificationService.getVisibleAnnouncements(position));
    }

    @PatchMapping("/{id}/archive")
    public ResponseEntity<Notification> archiveAnnouncement(@PathVariable Integer id) {
        return ResponseEntity.ok(notificationService.archiveAnnouncement(id));
    }

    // GET: Retrieve all notifications
    // Optional filters: ?type=OVERDUE or ?unread=true
    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications(
            @RequestParam(required = false) NotificationType type,
            @RequestParam(required = false) Boolean unread) {

        List<Notification> notifications;

        if (Boolean.TRUE.equals(unread)) {
            notifications = notificationService.getUnreadNotifications();
        } else if (type != null) {
            notifications = notificationService
                    .getNotificationsByType(type);
        } else {
            notifications = notificationService.getAllNotifications();
        }

        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/student/{userId}")
    public ResponseEntity<List<Notification>> getStudentNotifications(@PathVariable Integer userId) {
        return ResponseEntity.ok(notificationService.getStudentNotifications(userId));
    }

    // GET: Retrieve notifications for Librarian Desk
    @GetMapping("/librarian")
    public ResponseEntity<List<Notification>> getLibrarianNotifications(
            @RequestParam(required = false) String position) {

        return ResponseEntity.ok(
                notificationService.getLibrarianNotifications(position));
    }

    // GET: Retrieve unread notifications for Librarian Desk
    @GetMapping("/librarian/unread")
    public ResponseEntity<List<Notification>> getUnreadLibrarianNotifications(
            @RequestParam(required = false) String position) {

        return ResponseEntity.ok(
                notificationService.getUnreadLibrarianNotifications(position));
    }

    // POST: Create a notification
    @PostMapping
    public ResponseEntity<Notification> createNotification(
            @RequestBody Notification notification) {

        Notification created =
                notificationService.createNotification(notification);

        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // PATCH: Mark notification as read
    @PatchMapping("/{id}/read")
    public ResponseEntity<Notification> markAsRead(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                notificationService.markAsRead(id));
    }

    // DELETE: Delete notification
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNotification(
            @PathVariable Integer id) {

        notificationService.deleteNotification(id);

        return ResponseEntity.noContent().build();
    }
}
