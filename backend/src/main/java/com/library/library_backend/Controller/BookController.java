package com.library.library_backend.Controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
import com.library.library_backend.dto.BookRequest;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.Category;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.CategoryRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {

    private final BookService bookService;
    private final CategoryRepository categoryRepository;

    public BookController(
            BookService bookService,
            CategoryRepository categoryRepository) {

        this.bookService = bookService;
        this.categoryRepository = categoryRepository;
    }

    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBookResponses();
    }

    /** Categories shown in the book form dropdown. */
    @GetMapping("/categories")
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @GetMapping("/{bookId}")
    public BookResponse getBookById(@PathVariable Integer bookId) {
        return bookService.getBookResponseById(bookId);
    }

    @PostMapping
    public ResponseEntity<BookResponse> createBook(
            @Valid @RequestBody BookRequest request) {

        BookResponse savedBook = bookService.createBook(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(savedBook);
    }

    @PutMapping("/{bookId}")
    public book updateBook(
            @PathVariable Integer bookId,
            @RequestBody book updatedBook) {

        return bookService.updateBook(bookId, updatedBook);
    }

    @DeleteMapping("/{bookId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable Integer bookId) {
        bookService.deleteBook(bookId);
    }
}
