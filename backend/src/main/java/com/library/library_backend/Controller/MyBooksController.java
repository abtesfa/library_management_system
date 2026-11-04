package com.library.library_backend.Controller;

import com.library.library_backend.Service.MyBooksService;
import com.library.library_backend.dto.MyBookResponse;
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
}