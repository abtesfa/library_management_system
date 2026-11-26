package com.library.library_backend.Controller;

import com.library.library_backend.Service.StudentDashboardService;
import com.library.library_backend.dto.StudentDashboardResponse;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(origins = "*")
public class StudentDashboardController {

    private final StudentDashboardService dashboardService;

    public StudentDashboardController(
            StudentDashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/{id}/dashboard")
    public ResponseEntity<StudentDashboardResponse> getDashboard(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                dashboardService.getDashboard(id)
        );
    }
}