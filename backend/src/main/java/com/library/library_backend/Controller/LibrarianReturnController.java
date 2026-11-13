package com.library.library_backend.Controller;

import com.library.library_backend.dto.ReturnBookRequest;
import com.library.library_backend.dto.ReturnBookResponse;
import com.library.library_backend.dto.ActiveBorrowingResponse;
import com.library.library_backend.Service.LibrarianReturnService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/librarian")
@CrossOrigin(origins = "*")
public class LibrarianReturnController {

    private final LibrarianReturnService returnService;

    public LibrarianReturnController(
            LibrarianReturnService returnService
    ) {
        this.returnService = returnService;
    }

    @GetMapping("/active-borrowing")
    public ResponseEntity<?> findActiveBorrowing(
            @RequestParam String studentId,
            @RequestParam String bookQuery
    ) {
        try {
            ActiveBorrowingResponse response =
                    returnService.findActiveBorrowing(
                            studentId,
                            bookQuery
                    );

            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/return")
    public ResponseEntity<?> returnBook(
            @RequestBody ReturnBookRequest request
    ) {
        try {
            ReturnBookResponse response =
                    returnService.returnBook(request);

            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));

        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", e.getMessage()));
        }
    }
}