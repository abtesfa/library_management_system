package com.library.library_backend.Service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import com.library.library_backend.exception.ResourceNotFoundException;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.Author;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Category;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.AuthorRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.CategoryRepository;
import com.library.library_backend.dto.BookRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
@Service
public class BookService {

    private final BookRepository bookRepository;
    private final AuthorRepository authorRepository;
    private final CategoryRepository categoryRepository;
    private final BookCopyRepository bookCopyRepository;

    public BookService(
            BookRepository bookRepository,
            AuthorRepository authorRepository,
            CategoryRepository categoryRepository,
            BookCopyRepository bookCopyRepository) {

        this.bookRepository = bookRepository;
        this.authorRepository = authorRepository;
        this.categoryRepository = categoryRepository;
        this.bookCopyRepository = bookCopyRepository;
    }

    // Get all books in Flutter format
    public List<BookResponse> getAllBookResponses() {
        return bookRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .toList();
    }
public List<BookResponse> searchBooks(String keyword) {

    return bookRepository
            .findByTitleContainingIgnoreCase(keyword)
            .stream()
            .map(this::convertToResponse)
            .toList();
}
public List<BookResponse> searchBooksByAuthor(String name) {

    return bookRepository
            .findByAuthor_AuthorNameContainingIgnoreCase(name)
            .stream()
            .map(this::convertToResponse)
            .toList();
}
   public Page<BookResponse> getBooksWithPagination(Pageable pageable) {

    return bookRepository.findAll(pageable)
            .map(this::convertToResponse);
}
    // Get one book in Flutter format
    public BookResponse getBookResponseByIsbn(String isbn) {
        return convertToResponse(getBookByIsbn(isbn));
    }
    public List<BookResponse> advancedSearch(
        String title,
        String author,
        String category) {

    return bookRepository.advancedSearch(
            title, author, category
    )
    .stream()
    .map(this::convertToResponse)
    .toList();
}
public List<BookResponse> searchBooksByCategory(String name) {

    return bookRepository
            .findBooksByCategoryName(name)
            .stream()
            .map(this::convertToResponse)
            .toList();
}
    // Convert database records into a Flutter-compatible response
    private BookResponse convertToResponse(book b) {

        String authorName = authorRepository.findById(b.getAuthorId())
                .map(Author::getAuthorName)
                .orElse("Unknown Author");

        String categoryName = categoryRepository.findById(b.getCategoryId())
                .map(Category::getCategoryName)
                .orElse("General");

        int totalCopies = Math.toIntExact(
                bookCopyRepository.countByIsbn(b.getIsbn()));

        int availableCopies = Math.toIntExact(
                bookCopyRepository.countByIsbnAndStatus(
                        b.getIsbn(), "Available"));

        Optional<BookCopy> copy = bookCopyRepository
                .findFirstByIsbnAndStatus(b.getIsbn(), "Available");

        if (copy.isEmpty()) {
            copy = bookCopyRepository.findFirstByIsbn(b.getIsbn());
        }

        String location = copy
                .map(BookCopy::getLocation)
                .orElse("Not assigned");

        String status;

        if (availableCopies > 0) {
            status = "Available";
        } else if (totalCopies == 0) {
            status = "No Copies";
        } else {
            status = "Unavailable";
        }

        return new BookResponse(
                b.getIsbn(),
                b.getTitle(),
                authorName,
                b.getIsbn(),
                categoryName,
                totalCopies,
                availableCopies,
                status,
                location,
                b.getCoverImage()
        );
    }

    // Existing CRUD operations

    public List<book> getAllBooks() {
        return bookRepository.findAll();
    }

  public book getBookByIsbn(String isbn) {
    return bookRepository.findById(isbn)
        .orElseThrow(() ->
            new ResourceNotFoundException(
                "Book not found: " + isbn
            )
        );
}
   public BookResponse createBook(BookRequest request) {
    // 1. Check whether the ISBN already exists
    if (bookRepository.existsById(request.getIsbn())) {
        throw new IllegalArgumentException(
            "A book with this ISBN already exists"
        );
    }

    // 2. Create a new book Entity
    book newBook = new book();

    // 3. Transfer data from DTO to Entity
    newBook.setIsbn(request.getIsbn());
    newBook.setTitle(request.getTitle());
    newBook.setDescription(request.getDescription());
    newBook.setAuthorId(request.getAuthorId());
    newBook.setPublisherId(request.getPublisherId());
    newBook.setCategoryId(request.getCategoryId());
    newBook.setEdition(request.getEdition());
    newBook.setPrice(request.getPrice());
    newBook.setPublicationYear(request.getPublicationYear());
    newBook.setCoverImage(request.getCoverImage());

    // 4. Save the Entity into MySQL
   book savedBook = bookRepository.save(newBook);

    return convertToResponse(savedBook);
}

    public book updateBook(String isbn, book updatedBook) {
        book existingBook = getBookByIsbn(isbn);

        existingBook.setTitle(updatedBook.getTitle());
        existingBook.setDescription(updatedBook.getDescription());
        existingBook.setAuthorId(updatedBook.getAuthorId());
        existingBook.setPublisherId(updatedBook.getPublisherId());
        existingBook.setCategoryId(updatedBook.getCategoryId());
        existingBook.setEdition(updatedBook.getEdition());
        existingBook.setPrice(updatedBook.getPrice());
        existingBook.setPublicationYear(updatedBook.getPublicationYear());
        existingBook.setCoverImage(updatedBook.getCoverImage());

        return bookRepository.save(existingBook);
    }

    public void deleteBook(String isbn) {
        book existingBook = getBookByIsbn(isbn);
        bookRepository.delete(existingBook);
    }
}