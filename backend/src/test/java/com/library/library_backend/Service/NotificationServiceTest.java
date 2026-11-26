package com.library.library_backend.Service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.library.library_backend.entity.Notification;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.NotificationRepository;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private BorrowingRepository borrowingRepository;

    private NotificationService notificationService;

    @BeforeEach
    void setUp() {
        notificationService = new NotificationService(
                notificationRepository,
                borrowingRepository);
    }

    @Test
    void createsDueSoonAndOverdueNotificationsForActiveLoans() {
        when(notificationRepository.findByBorrowingIdIsNotNull())
                .thenReturn(List.of());
        when(borrowingRepository.findActiveBorrowingsForNotifications())
                .thenReturn(List.of(
                        loan(1, LocalDate.now().plusDays(7)),
                        loan(2, LocalDate.now().minusDays(1)),
                        loan(3, LocalDate.now().plusDays(8))));

        notificationService.getLibrarianNotifications();

        ArgumentCaptor<Notification> saved =
                ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository, org.mockito.Mockito.times(2))
                .save(saved.capture());
        assertEquals(
                List.of(
                        NotificationType.DUE_SOON,
                        NotificationType.OVERDUE),
                saved.getAllValues().stream()
                        .map(Notification::getNotificationType)
                        .toList());
        assertEquals(
                List.of(1, 2),
                saved.getAllValues().stream()
                        .map(Notification::getBorrowingId)
                        .toList());
    }

    @Test
    void removesLoanNotificationsWhenLoansAreNoLongerActive() {
        Notification previous = notification(12, NotificationType.OVERDUE);
        when(notificationRepository.findByBorrowingIdIsNotNull())
                .thenReturn(List.of(previous));
        when(borrowingRepository.findActiveBorrowingsForNotifications())
                .thenReturn(List.<Object[]>of());

        notificationService.getLibrarianNotifications();

        verify(notificationRepository).deleteAll(List.of(previous));
        verify(notificationRepository, never()).save(any(Notification.class));
    }

    @Test
    void preservesExistingReadStateAndDoesNotDuplicateCurrentLoanAlert() {
        Notification existing = notification(7, NotificationType.DUE_SOON);
        existing.setIsRead(true);
        LocalDate dueDate = LocalDate.now().plusDays(2);
        existing.setTitle("Book Due Soon");
        existing.setMessage("\"Test Book\" borrowed by Test Student (ST-1) "
                + "is due on " + dueDate + ".");
        existing.setDetails(
                "Borrowing ID: 7 | Due date: " + dueDate);
        when(notificationRepository.findByBorrowingIdIsNotNull())
                .thenReturn(List.of(existing));
        when(borrowingRepository.findActiveBorrowingsForNotifications())
                .thenReturn(List.<Object[]>of(
                        loan(7, dueDate)));

        notificationService.getLibrarianNotifications();

        verify(notificationRepository, never()).save(any(Notification.class));
        verify(notificationRepository, never()).deleteAll(any());
        assertEquals(true, existing.getIsRead());
    }

    private Object[] loan(Integer borrowingId, LocalDate dueDate) {
        return new Object[] {
                borrowingId,
                dueDate,
                "Test Student",
                "ST-1",
                "Test Book"
        };
    }

    private Notification notification(
            Integer borrowingId,
            NotificationType type) {
        Notification notification = new Notification();
        notification.setBorrowingId(borrowingId);
        notification.setNotificationType(type);
        notification.setRecipientType("LIBRARIAN");
        notification.setTitle("Loan alert");
        notification.setMessage("Loan alert");
        notification.setDetails("Loan alert");
        notification.setIsRead(false);
        return notification;
    }
}
