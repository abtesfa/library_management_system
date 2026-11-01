
package com.library.library_backend.Controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import com.library.library_backend.Service.BookService;
import com.library.library_backend.dto.BookRequest;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.book;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    // Get all books
    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBookResponses();
    }

    // Search by title
    @GetMapping("/search")
    public List<BookResponse> searchBooks(
            @RequestParam String keyword) {
        return bookService.searchBooks(keyword);
    }

    // Search by author
    @GetMapping("/search/author")
    public List<BookResponse> searchBooksByAuthor(
            @RequestParam String name) {
        return bookService.searchBooksByAuthor(name);
    }

    // Search by category
    @GetMapping("/search/category")
    public List<BookResponse> searchBooksByCategory(
            @RequestParam String name) {
        return bookService.searchBooksByCategory(name);
    }

    // Advanced search
    @GetMapping("/advanced-search")
    public List<BookResponse> advancedSearch(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String author,
            @RequestParam(required = false) String category) {

        return bookService.advancedSearch(title, author, category);
    }

    // Pagination
    @GetMapping("/page")
    public Page<BookResponse> getBooksWithPagination(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        Pageable pageable = PageRequest.of(page, size);
        return bookService.getBooksWithPagination(pageable);
    }

    // Get one book by Book_ID
    @GetMapping("/{bookId}")
    public BookResponse getBookById(@PathVariable Integer bookId) {
        return bookService.getBookResponseById(bookId);
    }

    // Create a new book
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BookResponse createBook(
            @Valid @RequestBody BookRequest request) {
        return bookService.createBook(request);
    }

    // Update an existing book by Book_ID
    @PutMapping("/{bookId}")
    public book updateBook(
            @PathVariable Integer bookId,
            @RequestBody book updatedBook) {

        return bookService.updateBook(bookId, updatedBook);
    }

    // Delete a book by Book_ID
    @DeleteMapping("/{bookId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable Integer bookId) {
        bookService.deleteBook(bookId);
    }
}
