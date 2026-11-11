package com.library.library_backend.Controller;

import com.library.library_backend.Service.MyBooksService;
import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.dto.RenewBookResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(origins = "*")
public class MyBooksController {

    private final MyBooksService myBooksService;

    public MyBooksController(MyBooksService myBooksService) {
        this.myBooksService = myBooksService;
    }

    @GetMapping("/{userId}/borrowings")
    public ResponseEntity<List<MyBookResponse>> getMyBooks(
            @PathVariable Integer userId) {

        return ResponseEntity.ok(
                myBooksService.getMyBooks(userId)
        );
    }

    /** Renews one of the student's active loans (one renewal only). */
    @PostMapping("/{userId}/borrowings/{borrowingId}/renew")
    public ResponseEntity<RenewBookResponse> renewBook(
            @PathVariable Integer userId,
            @PathVariable Integer borrowingId) {

        return ResponseEntity.ok(
                myBooksService.renewBook(userId, borrowingId)
        );
    }
}
