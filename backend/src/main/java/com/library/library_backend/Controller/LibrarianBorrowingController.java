package com.library.library_backend.Controller;

import com.library.library_backend.dto.BorrowBookRequest;
import com.library.library_backend.dto.BorrowBookResponse;
import com.library.library_backend.Service.LibrarianBorrowingService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/librarian")
@CrossOrigin(origins = "*")
public class LibrarianBorrowingController {

    private final LibrarianBorrowingService borrowingService;

    public LibrarianBorrowingController(
            LibrarianBorrowingService borrowingService
    ) {
        this.borrowingService = borrowingService;
    }

    @PostMapping("/borrow")
    public ResponseEntity<?> borrowBook(
            @RequestBody BorrowBookRequest request
    ) {
        try {
            BorrowBookResponse response =
                    borrowingService.borrowBook(request);

            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(response);

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(Map.of("message", e.getMessage()));

        } catch (IllegalStateException e) {

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", e.getMessage()));
        }
    }
}