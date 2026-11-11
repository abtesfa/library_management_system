
package com.library.library_backend.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.library.library_backend.dto.BookRequest;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.Author;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Category;
import com.library.library_backend.entity.book;
import com.library.library_backend.exception.ResourceNotFoundException;
import com.library.library_backend.repository.AuthorRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.CategoryRepository;
import com.library.library_backend.repository.ReservationRepository;

@Service
@Transactional
public class BookService {

    private final BookRepository bookRepository;
    private final AuthorRepository authorRepository;
    private final CategoryRepository categoryRepository;
    private final BookCopyRepository bookCopyRepository;
    private final ReservationRepository reservationRepository;

    public BookService(
            BookRepository bookRepository,
            AuthorRepository authorRepository,
            CategoryRepository categoryRepository,
            BookCopyRepository bookCopyRepository,
            ReservationRepository reservationRepository) {

        this.bookRepository = bookRepository;
        this.authorRepository = authorRepository;
        this.categoryRepository = categoryRepository;
        this.bookCopyRepository = bookCopyRepository;
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

        // These fields are not required in the new Flutter form
        newBook.setDescription(null);
        newBook.setIsbn(null);
        newBook.setPublisherId(null);

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

    // ==========================================
    // UPDATE BOOK
    // ==========================================

    public book updateBook(Integer bookId, book updatedBook) {

        book existingBook = getBookById(bookId);

        existingBook.setTitle(updatedBook.getTitle());
        existingBook.setDescription(updatedBook.getDescription());

        // Update author if a valid author ID is supplied
        if (updatedBook.getAuthorId() != null) {

            Author author = authorRepository
                    .findById(updatedBook.getAuthorId())
                    .orElseThrow(() ->
                            new ResourceNotFoundException(
                                    "Author not found: "
                                            + updatedBook.getAuthorId()
                            )
                    );

            existingBook.setAuthor(author);
        }

        // Update optional fields
        existingBook.setPublisherId(updatedBook.getPublisherId());
        existingBook.setCategoryId(updatedBook.getCategoryId());
        existingBook.setEdition(updatedBook.getEdition());
        existingBook.setPrice(updatedBook.getPrice());

        existingBook.setPublicationYear(
                updatedBook.getPublicationYear()
        );

        existingBook.setCoverImage(updatedBook.getCoverImage());

        // Update ISBN if supplied
        if (updatedBook.getIsbn() != null) {

            String isbn = updatedBook.getIsbn().trim();

            if (!isbn.isEmpty()
                    && bookRepository.findByIsbn(isbn)
                            .filter(b -> !b.getBookId().equals(bookId))
                            .isPresent()) {

                throw new IllegalArgumentException(
                        "Another book already uses this ISBN."
                );
            }

            existingBook.setIsbn(
                    isbn.isEmpty() ? null : isbn
            );
        }

        return bookRepository.save(existingBook);
    }

    // ==========================================
    // DELETE BOOK
    // ==========================================

    public void deleteBook(Integer bookId) {

        book existingBook = getBookById(bookId);

        // Prevent deletion when physical copies exist
        if (bookCopyRepository.countByBookId(bookId) > 0) {

            throw new IllegalStateException(
                    "Cannot delete this book because physical copies exist. "
                            + "Remove its copies first."
            );
        }

        bookRepository.delete(existingBook);
    }
}
