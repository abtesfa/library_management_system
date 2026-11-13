
package com.library.library_backend.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.library.library_backend.dto.BookRequest;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.dto.BookUpdateRequest;
import com.library.library_backend.entity.Author;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Category;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.book;
import com.library.library_backend.exception.ResourceNotFoundException;
import com.library.library_backend.repository.AuthorRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.CategoryRepository;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.NotificationRepository;
import com.library.library_backend.repository.ReservationRepository;

@Service
@Transactional
public class BookService {

    private final BookRepository bookRepository;
    private final AuthorRepository authorRepository;
    private final CategoryRepository categoryRepository;
    private final BookCopyRepository bookCopyRepository;
    private final BorrowingRepository borrowingRepository;
    private final NotificationRepository notificationRepository;
    private final ReservationRepository reservationRepository;

    public BookService(
            BookRepository bookRepository,
            AuthorRepository authorRepository,
            CategoryRepository categoryRepository,
            BookCopyRepository bookCopyRepository,
            BorrowingRepository borrowingRepository,
            NotificationRepository notificationRepository,
            ReservationRepository reservationRepository) {

        this.bookRepository = bookRepository;
        this.authorRepository = authorRepository;
        this.categoryRepository = categoryRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.borrowingRepository = borrowingRepository;
        this.notificationRepository = notificationRepository;
        this.reservationRepository = reservationRepository;
    }

    // ==========================================
    // GET ALL BOOKS
    // ==========================================

    public List<BookResponse> getAllBookResponses() {

        return bookRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .toList();
    }

    // ==========================================
    // GET BOOK BY BOOK_ID
    // ==========================================

    public book getBookById(Integer bookId) {

        return bookRepository.findById(bookId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Book not found with ID: " + bookId
                        )
                );
    }

    public BookResponse getBookResponseById(Integer bookId) {

        return convertToResponse(getBookById(bookId));
    }

    // ==========================================
    // CONVERT BOOK ENTITY TO RESPONSE
    // ==========================================

    private BookResponse convertToResponse(book b) {

        // Get author name
        String authorName = b.getAuthor() != null
                ? b.getAuthor().getAuthorName()
                : "Unknown Author";

        // Get category name
        String categoryName = "General";

        if (b.getCategoryId() != null) {

            categoryName = categoryRepository
                    .findById(b.getCategoryId())
                    .map(Category::getCategoryName)
                    .orElse("General");
        }

        // Get Book ID
        Integer bookId = b.getBookId();

        // Count all physical copies
        int totalCopies = Math.toIntExact(
                bookCopyRepository.countByBookId(bookId)
        );

        // Copies on the shelf, minus the ones held by active reservations.
        // A reserved copy is not available to other students.
        int copiesOnShelf = Math.toIntExact(
                bookCopyRepository.countByBookIdAndStatus(
                        bookId,
                        "Available"
                )
        );

        int reservedCopies = (int) Math.min(
                copiesOnShelf,
                reservationRepository.countActiveByBookId(bookId)
        );

        int availableCopies = copiesOnShelf - reservedCopies;

        // Find a copy to obtain its shelf location
        Optional<BookCopy> copy =
                bookCopyRepository.findFirstByBookIdAndStatus(
                        bookId,
                        "Available"
                );

        if (copy.isEmpty()) {
            copy = bookCopyRepository.findFirstByBookId(bookId);
        }

        String location = copy
                .map(BookCopy::getLocation)
                .orElse("Not assigned");

        // Determine book availability
        String status;

        if (availableCopies > 0) {
            status = "Available";
        } else if (totalCopies == 0) {
            status = "No Copies";
        } else {
            status = "Unavailable";
        }

        return new BookResponse(
                String.valueOf(bookId),
                b.getTitle(),
                authorName,
                b.getIsbn(),
                categoryName,
                totalCopies,
                availableCopies,
                reservedCopies,
                status,
                location,
                b.getCoverImage(),
                b.getPublisherName(),
                b.getEdition(),
                b.getPublicationYear(),
                b.getDescription(),
                b.getCoverImage()
        );
    }

    // ==========================================
    // CREATE BOOK
    // ==========================================

    public BookResponse createBook(BookRequest request) {

        // 1. Validate the request
        if (request.getNumberOfCopies() == null
                || request.getNumberOfCopies() < 1) {

            throw new IllegalArgumentException(
                    "At least one physical copy is required."
            );
        }

        if (request.getCategoryId() == null) {

            throw new IllegalArgumentException(
                    "Please select a book category."
            );
        }

        // 2. Find existing author or create a new author
        String authorName = request.getAuthorName().trim();

        Author author = authorRepository
                .findByAuthorNameIgnoreCase(authorName)
                .orElseGet(() -> {

                    Author newAuthor = new Author();
                    newAuthor.setAuthorName(authorName);

                    return authorRepository.save(newAuthor);
                });

        // 3. Find selected category
        Category category = categoryRepository
                .findById(request.getCategoryId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Category not found with ID: "
                                        + request.getCategoryId()
                        )
                );

        // 4. Create book
        book newBook = new book();

        newBook.setTitle(request.getTitle().trim());
        newBook.setAuthor(author);
        newBook.setCategoryId(category.getCategoryId());

        String isbn = request.getIsbn();
        if (isbn != null && !isbn.isBlank()) {
            isbn = isbn.trim();
            if (bookRepository.findByIsbn(isbn).isPresent()) {
                throw new IllegalArgumentException(
                        "Another book already uses this ISBN."
                );
            }
        } else {
            isbn = null;
        }

        newBook.setIsbn(isbn);
        newBook.setDescription(blankToNull(request.getDescription()));
        newBook.setPublisherId(null);
        newBook.setPublisherName(blankToNull(request.getPublisher()));
        newBook.setEdition(blankToNull(request.getEdition()));
        newBook.setPublicationYear(request.getPublicationYear());
        newBook.setCoverImage(blankToNull(request.getCoverImage()));

        // 5. Save book
        book savedBook = bookRepository.save(newBook);

        // 6. Create physical copies
        List<BookCopy> copies = new ArrayList<>();

        String location = request.getLocation();

        if (location != null && location.isBlank()) {
            location = null;
        } else if (location != null) {
            location = location.trim();
        }

      for (int i = 0; i < request.getNumberOfCopies(); i++) {

    BookCopy copy = new BookCopy();

    copy.setBookId(savedBook.getBookId());
    copy.setStatus("Available");
    copy.setLocation(location);


    copies.add(copy);
}

        // 7. Save all physical copies
        bookCopyRepository.saveAll(copies);

        // 8. Return saved book with copy information
        return convertToResponse(savedBook);
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    // ==========================================
    // UPDATE BOOK
    // ==========================================

    public BookResponse updateBook(
            Integer bookId,
            BookUpdateRequest request) {
        book existingBook = getBookById(bookId);

        String authorName = request.getAuthorName().trim();
        Author author = authorRepository
                .findByAuthorNameIgnoreCase(authorName)
                .orElseGet(() -> {
                    Author newAuthor = new Author();
                    newAuthor.setAuthorName(authorName);
                    return authorRepository.save(newAuthor);
                });

        Category category = categoryRepository
                .findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found: " + request.getCategoryId()));

        String isbn = blankToNull(request.getIsbn());
        if (isbn != null
                && bookRepository.findByIsbn(isbn)
                        .filter(book -> !book.getBookId().equals(bookId))
                        .isPresent()) {
            throw new IllegalArgumentException(
                    "Another book already uses this ISBN.");
        }

        existingBook.setTitle(request.getTitle().trim());
        existingBook.setAuthor(author);
        existingBook.setCategoryId(category.getCategoryId());
        existingBook.setIsbn(isbn);
        existingBook.setDescription(blankToNull(request.getDescription()));
        existingBook.setPublisherName(blankToNull(request.getPublisher()));
        existingBook.setEdition(blankToNull(request.getEdition()));
        existingBook.setPublicationYear(request.getPublicationYear());
        existingBook.setCoverImage(blankToNull(request.getCoverImage()));

        book savedBook = bookRepository.save(existingBook);
        bookCopyRepository.updateLocationByBookId(
                bookId,
                blankToNull(request.getLocation()));

        return convertToResponse(savedBook);
    }

    // ==========================================
    // DELETE BOOK
    // ==========================================

    public void deleteBook(Integer bookId) {
        book existingBook = getBookById(bookId);

        List<Reservation> reservations =
                reservationRepository.findAllByBookId(bookId);
        List<Integer> reservationIds = reservations.stream()
                .map(Reservation::getReservationId)
                .toList();

        if (!reservationIds.isEmpty()) {
            notificationRepository.deleteAllByReservationIdIn(
                    reservationIds);
        }

        reservationRepository.deleteAll(reservations);

        List<BookCopy> copies = bookCopyRepository.findAllByBookId(bookId);
        List<Integer> copyIds = copies.stream()
                .map(BookCopy::getCopyId)
                .toList();

        if (!copyIds.isEmpty()) {
            borrowingRepository.deleteAllByCopyIdIn(copyIds);
        }

        bookCopyRepository.deleteAll(copies);
        bookRepository.delete(existingBook);
    }
}
