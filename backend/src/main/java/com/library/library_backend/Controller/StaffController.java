
package com.library.library_backend.Controller;

import com.library.library_backend.Service.StaffService;
import com.library.library_backend.dto.StaffRequest;
import com.library.library_backend.dto.StaffResponse;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/staff")
@CrossOrigin(origins = "*")
public class StaffController {

    private final StaffService staffService;

    public StaffController(StaffService staffService) {
        this.staffService = staffService;
    }

    // GET: Retrieve all staff members
    @GetMapping
    public ResponseEntity<List<StaffResponse>> getAllStaff() {
        return ResponseEntity.ok(staffService.getAllStaff());
    }

    // GET: Retrieve one staff member by ID
    @GetMapping("/{id}")
    public ResponseEntity<StaffResponse> getStaffById(
            @PathVariable Integer id) {
        return ResponseEntity.ok(staffService.getStaffById(id));
    }

    // POST: Create a new staff member
    @PostMapping
    public ResponseEntity<StaffResponse> createStaff(
            @RequestBody StaffRequest request) {

        StaffResponse response = staffService.createStaff(request);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // PUT: Update staff information
    @PutMapping("/{id}")
    public ResponseEntity<StaffResponse> updateStaff(
            @PathVariable Integer id,
            @RequestBody StaffRequest request) {

        return ResponseEntity.ok(
                staffService.updateStaff(id, request));
    }

    // PATCH: Activate or deactivate a staff member
    @PatchMapping("/{id}/status")
    public ResponseEntity<StaffResponse> updateStaffStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> request) {

        String status = request.get("status");

        return ResponseEntity.ok(
                staffService.updateStaffStatus(id, status));
    }
}
