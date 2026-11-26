package com.library.library_backend.Controller;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.library.library_backend.Service.BookService;
import com.library.library_backend.dto.BookRequest;
import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.dto.BookUpdateRequest;
import com.library.library_backend.entity.Category;
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

    /** Server-side catalogue pagination: /api/books/page?page=0&size=12 */
    @GetMapping("/page")
    public Page<BookResponse> getBooksPage(@PageableDefault(size = 12, sort = "title") Pageable pageable) {
        return bookService.getBookResponses(pageable);
    }

    public record DepartmentMappingRequest(String department) {}

    @PostMapping("/{bookId}/departments")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addDepartmentMapping(@PathVariable Integer bookId, @RequestBody DepartmentMappingRequest request) {
        bookService.addDepartmentMapping(bookId, request.department());
    }

    @DeleteMapping("/{bookId}/departments")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeDepartmentMapping(@PathVariable Integer bookId, @RequestParam String department) {
        bookService.removeDepartmentMapping(bookId, department);
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
    public BookResponse updateBook(
            @PathVariable Integer bookId,
            @Valid @RequestBody BookUpdateRequest updatedBook) {

        return bookService.updateBook(bookId, updatedBook);
    }

    @DeleteMapping("/{bookId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable Integer bookId) {
        bookService.deleteBook(bookId);
    }
}
