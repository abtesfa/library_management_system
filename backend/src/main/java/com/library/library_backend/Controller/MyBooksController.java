package com.library.library_backend.Controller;

import com.library.library_backend.Service.MyBooksService;
import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.dto.RenewBookResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;

import java.util.List;
import java.util.Map;

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


    @GetMapping("/{userId}/borrowings/history")
    public ResponseEntity<List<Map<String, Object>>> getBorrowingHistory(@PathVariable Integer userId) {
        return ResponseEntity.ok(myBooksService.getBorrowingHistory(userId));
    }

    @GetMapping("/{userId}/borrowings/history/page")
    public ResponseEntity<Page<Map<String, Object>>> getBorrowingHistoryPage(
            @PathVariable Integer userId,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(myBooksService.getBorrowingHistoryPage(userId, pageable));
    }

    /** Renews one of the student's active loans within configured policy limits. */
    @PostMapping("/{userId}/borrowings/{borrowingId}/renew")
    public ResponseEntity<RenewBookResponse> renewBook(
            @PathVariable Integer userId,
            @PathVariable Integer borrowingId) {

        return ResponseEntity.ok(
                myBooksService.renewBook(userId, borrowingId)
        );
    }
}
