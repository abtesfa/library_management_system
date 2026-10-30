
package com.library.library_backend.Controller;

import com.library.library_backend.entity.book;
import com.library.library_backend.Service.BookService;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
//Think of the controller as a reception desk at a library:
// it receives requests and directs them to the appropriate service.

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping
    public List<book> getAllBooks() {
        return bookService.getAllBooks();
    }

    @GetMapping("/{isbn}")
    public book getBookByIsbn(@PathVariable String isbn) {
        return bookService.getBookByIsbn(isbn);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public book createBook(@RequestBody book newBook) {
        return bookService.createBook(newBook);
    }

    @PutMapping("/{isbn}")
    public book updateBook(
            @PathVariable String isbn,
            @RequestBody book updatedBook) {
        return bookService.updateBook(isbn, updatedBook);
    }

    @DeleteMapping("/{isbn}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable String isbn) {
        bookService.deleteBook(isbn);
    }
}
