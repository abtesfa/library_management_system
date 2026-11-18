package com.library.library_backend.Service;

import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.entity.Student;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.StudentRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Service
public class BorrowingNotificationScheduler {

    private static final Logger logger = LoggerFactory.getLogger(BorrowingNotificationScheduler.class);

    private static final ZoneId LIBRARY_TIME_ZONE = ZoneId.of("Africa/Addis_Ababa");

    private final BorrowingRepository borrowingRepository;
    private final StudentRepository studentRepository;
    private final BookCopyRepository bookCopyRepository;
    private final BookRepository bookRepository;
    private final NotificationService notificationService;

    public BorrowingNotificationScheduler(
            BorrowingRepository borrowingRepository,
            StudentRepository studentRepository,
            BookCopyRepository bookCopyRepository,
            BookRepository bookRepository,
            NotificationService notificationService) {

        this.borrowingRepository = borrowingRepository;
        this.studentRepository = studentRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.bookRepository = bookRepository;
        this.notificationService = notificationService;
    }

    // Runs every day at 8:00 AM Ethiopia time
    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void checkBorrowingNotifications() {
        System.out.println("========== BORROWING NOTIFICATION SCHEDULER STARTED ==========");
        LocalDate today = LocalDate.now(LIBRARY_TIME_ZONE);
        LocalDate dueSoonLimit = today.plusDays(7);

        List<Borrowing> activeBorrowings = borrowingRepository.findByStatusIgnoreCase("BORROWED");

        logger.info(
                "Checking notifications for {} active borrowings.",
                activeBorrowings.size());

        for (Borrowing borrowing : activeBorrowings) {

            try {
                processBorrowing(
                        borrowing,
                        today,
                        dueSoonLimit);
            } catch (Exception exception) {
                logger.error(
                        "Could not process notifications for borrowing ID {}",
                        borrowing.getBorrowingId(),
                        exception);
            }
        }
    }

    private void processBorrowing(
            Borrowing borrowing,
            LocalDate today,
            LocalDate dueSoonLimit) {

        LocalDate dueDate = borrowing.getDueDate();

        if (dueDate == null) {
            logger.warn(
                    "Borrowing {} has no due date.",
                    borrowing.getBorrowingId());
            return;
        }

        // Find the student
        Student student = studentRepository
                .findById(borrowing.getUserId())
                .orElse(null);

        if (student == null) {
            logger.warn(
                    "Student not found for borrowing {}.",
                    borrowing.getBorrowingId());
            return;
        }

        // Find the borrowed copy
        BookCopy copy = bookCopyRepository
                .findById(borrowing.getCopyId())
                .orElse(null);

        if (copy == null) {
            logger.warn(
                    "Book copy not found for borrowing {}.",
                    borrowing.getBorrowingId());
            return;
        }

        // Find the book
        book selectedBook = bookRepository
                .findById(copy.getBookId())
                .orElse(null);

        if (selectedBook == null) {
            logger.warn(
                    "Book not found for borrowing {}.",
                    borrowing.getBorrowingId());
            return;
        }

        Integer borrowingId = borrowing.getBorrowingId();

        // Case 1: The due date has passed
        if (dueDate.isBefore(today)) {

            // Remove an old Due Soon notification
            notificationService.deleteByBorrowingIdAndType(
                    borrowingId,
                    NotificationType.DUE_SOON);

            // Create Overdue notification if it does not exist
            notificationService.createBorrowingNotification(
                    borrowingId,
                    student.getFullName(),
                    student.getStudentId(),
                    selectedBook.getTitle(),
                    dueDate,
                    NotificationType.OVERDUE);

        }

        // Case 2: The book is due today or within seven days
        else if (!dueDate.isAfter(dueSoonLimit)) {

            // Remove an old Overdue notification
            notificationService.deleteByBorrowingIdAndType(
                    borrowingId,
                    NotificationType.OVERDUE);

            // Create Due Soon notification if it does not exist
            notificationService.createBorrowingNotification(
                    borrowingId,
                    student.getFullName(),
                    student.getStudentId(),
                    selectedBook.getTitle(),
                    dueDate,
                    NotificationType.DUE_SOON);

        }

        // Case 3: The due date is more than seven days away
        else {

            // Remove outdated notifications
            notificationService.deleteByBorrowingIdAndType(
                    borrowingId,
                    NotificationType.DUE_SOON);

            notificationService.deleteByBorrowingIdAndType(
                    borrowingId,
                    NotificationType.OVERDUE);
        }
    }
}