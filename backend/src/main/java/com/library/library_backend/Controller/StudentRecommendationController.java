package com.library.library_backend.Controller;

import com.library.library_backend.Service.StudentRecommendationService;
import com.library.library_backend.dto.BookResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(origins = "*")
public class StudentRecommendationController {
    private final StudentRecommendationService service;
    public StudentRecommendationController(StudentRecommendationService service) { this.service = service; }
    @GetMapping("/{userId}/recommendations")
    public List<BookResponse> recommendations(@PathVariable Integer userId,
            @RequestParam(required = false) Integer categoryId) {
        return service.recommended(userId, categoryId);
    }
}
