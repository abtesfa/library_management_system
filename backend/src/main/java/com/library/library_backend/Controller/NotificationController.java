
package com.library.library_backend.Controller;

import com.library.library_backend.Service.NotificationService;
import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(
            NotificationService notificationService) {
        this.notificationService = notificationService;
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

    // GET: Retrieve notifications for Librarian Desk
    @GetMapping("/librarian")
    public ResponseEntity<List<Notification>> getLibrarianNotifications() {

        return ResponseEntity.ok(
                notificationService.getLibrarianNotifications());
    }

    // GET: Retrieve unread notifications for Librarian Desk
    @GetMapping("/librarian/unread")
    public ResponseEntity<List<Notification>> getUnreadLibrarianNotifications() {

        return ResponseEntity.ok(
                notificationService.getUnreadLibrarianNotifications());
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
