package com.library.library_backend.Service;

import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.AuthorRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.CategoryRepository;
import com.library.library_backend.repository.NotificationRepository;
import com.library.library_backend.repository.ReservationRepository;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @Mock
    private AuthorRepository authorRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private BookCopyRepository bookCopyRepository;

    @Mock
    private BorrowingRepository borrowingRepository;

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private ReservationRepository reservationRepository;

    private BookService bookService;

    @BeforeEach
    void setUp() {
        bookService = new BookService(
                bookRepository,
                authorRepository,
                categoryRepository,
                bookCopyRepository,
                borrowingRepository,
                notificationRepository,
                reservationRepository);
    }

    @Test
    void deleteBookRemovesRelatedHistoryBeforeCopiesAndBook() {
        book existingBook = new book();
        existingBook.setBookId(7);

        Reservation reservation = new Reservation();
        reservation.setReservationId(31);

        BookCopy copy = new BookCopy();
        copy.setCopyId(41);

        when(bookRepository.findById(7)).thenReturn(Optional.of(existingBook));
        when(reservationRepository.findAllByBookId(7))
                .thenReturn(List.of(reservation));
        when(bookCopyRepository.findAllByBookId(7))
                .thenReturn(List.of(copy));

        bookService.deleteBook(7);

        InOrder deletionOrder = inOrder(
                notificationRepository,
                reservationRepository,
                borrowingRepository,
                bookCopyRepository,
                bookRepository);
        deletionOrder.verify(notificationRepository)
                .deleteAllByReservationIdIn(List.of(31));
        deletionOrder.verify(reservationRepository)
                .deleteAll(List.of(reservation));
        deletionOrder.verify(borrowingRepository)
                .deleteAllByCopyIdIn(List.of(41));
        deletionOrder.verify(bookCopyRepository)
                .deleteAll(List.of(copy));
        deletionOrder.verify(bookRepository).delete(existingBook);

        verify(bookRepository).findById(7);
    }
}
