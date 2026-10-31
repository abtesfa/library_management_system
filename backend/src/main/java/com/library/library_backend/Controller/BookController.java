package com.library.library_backend.Controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.library.library_backend.Service.BookService;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.book;
import jakarta.validation.Valid;
import com.library.library_backend.dto.BookRequest;
import org.springframework.web.bind.annotation.RequestParam;
@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    // Get all books with author, category and copy information
    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBookResponses();
    }
    @GetMapping("/search")
public List<BookResponse> searchBooks(
        @RequestParam String keyword) {

    return bookService.searchBooks(keyword);
}
   @GetMapping("/search/author")
   public List<BookResponse> searchBooksByAuthor(
        @RequestParam String name) {

    return bookService.searchBooksByAuthor(name);
}
@GetMapping("/search/category")
public List<BookResponse> searchBooksByCategory(
        @RequestParam String name) {

    return bookService.searchBooksByCategory(name);
}
    // Get one book by ISBN
    @GetMapping("/{isbn}")
    public BookResponse getBookByIsbn(@PathVariable String isbn) {
        return bookService.getBookResponseByIsbn(isbn);
    }

    // Create a new book
   @PostMapping
   @ResponseStatus(HttpStatus.CREATED)
   public BookResponse createBook(
        @Valid @RequestBody BookRequest request) {

    return bookService.createBook(request);
   }

    // Update an existing book
    @PutMapping("/{isbn}")
    public book updateBook(
            @PathVariable String isbn,
            @RequestBody book updatedBook) {

        return bookService.updateBook(isbn, updatedBook);
    }

    // Delete a book
    @DeleteMapping("/{isbn}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable String isbn) {
        bookService.deleteBook(isbn);
    }
}