
package com.library.library_backend.Service;

import com.library.library_backend.dto.StaffRequest;
import com.library.library_backend.dto.StaffResponse;
import com.library.library_backend.entity.Permission;
import com.library.library_backend.entity.Staff;
import com.library.library_backend.repository.PermissionRepository;
import com.library.library_backend.repository.StaffRepository;
import com.library.library_backend.security.PasswordHashService;

import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.Collectors;

@Service
public class StaffService {

    private static final Map<String, String> PERMISSION_DESCRIPTIONS = Map.of(
            "ADD_BOOK", "Add books to the inventory",
            "EDIT_BOOK", "Edit book information",
            "DELETE_BOOK", "Delete books from the inventory",
            "BORROW_BOOK", "Issue books to readers",
            "RETURN_BOOK", "Process returned books",
            "CONFIGURE_SETTINGS", "Configure library settings",
            "MANAGE_STAFF", "Manage staff accounts",
            "VIEW_NOTIFICATIONS", "View librarian notifications");

    private final StaffRepository staffRepository;
    private final PermissionRepository permissionRepository;
    private final PasswordHashService passwordHashService;

    public StaffService(
            StaffRepository staffRepository,
            PermissionRepository permissionRepository,
            PasswordHashService passwordHashService) {
        this.staffRepository = staffRepository;
        this.permissionRepository = permissionRepository;
        this.passwordHashService = passwordHashService;
    }

    // Get all staff members
    public List<StaffResponse> getAllStaff() {
        return staffRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    // Get one staff member by ID
    public StaffResponse getStaffById(Integer id) {
        Staff staff = staffRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Staff member not found"));

        return convertToResponse(staff);
    }

    // Create a staff member
    @Transactional
    public StaffResponse createStaff(StaffRequest request) {

        validateStaffRequest(request);

        if (request.getPassword() == null
                || request.getPassword().length() < 8) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Password must be at least 8 characters");
        }

        if (staffRepository.existsByEmail(request.getEmail().trim().toLowerCase())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT, "Email already exists");
        }

        Staff staff = new Staff();

        staff.setFullName(request.getFullName().trim());
        staff.setEmail(request.getEmail().trim().toLowerCase());
        staff.setPhoneNumber(request.getPhoneNumber());
        staff.setPasswordHash(passwordHashService.hash(request.getPassword()));
        staff.setStatus("ACTIVE");
        staff.setMustChangePassword(true);
        staff.setTokenVersion(0);

        applyRoleAndPermissions(staff, request);

        Staff savedStaff = staffRepository.save(staff);

        return convertToResponse(savedStaff);
    }

    // Update an existing staff member
    @Transactional
    public StaffResponse updateStaff(Integer id, StaffRequest request) {

        validateStaffRequest(request);

        Staff staff = staffRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Staff member not found"));

        String newEmail = request.getEmail().trim().toLowerCase();

        staffRepository.findByEmailIgnoreCase(newEmail).ifPresent(existing -> {
            if (!existing.getStaffId().equals(id)) {
                throw new ResponseStatusException(
                        HttpStatus.CONFLICT, "Email already exists");
            }
        });

        staff.setFullName(request.getFullName().trim());
        staff.setEmail(newEmail);
        staff.setPhoneNumber(request.getPhoneNumber());

        applyRoleAndPermissions(staff, request);

        if (request.getStatus() != null) {
            if (!request.getStatus().equals("ACTIVE")
                    && !request.getStatus().equals("INACTIVE")) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Invalid staff status");
            }

            if (staff.getStatus().equals("ACTIVE")
                    && request.getStatus().equals("INACTIVE")) {
                staff.setTokenVersion(staff.getTokenVersion() + 1);
            }

            staff.setStatus(request.getStatus());
        }

        return convertToResponse(staffRepository.save(staff));
    }

    // Activate or deactivate a staff member
    @Transactional
    public StaffResponse updateStaffStatus(Integer id, String status) {

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Status must be ACTIVE or INACTIVE");
        }

        Staff staff = staffRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Staff member not found"));

        if (staff.getStatus().equals("ACTIVE")
                && status.equals("INACTIVE")) {
            staff.setTokenVersion(staff.getTokenVersion() + 1);
        }

        staff.setStatus(status);

        return convertToResponse(staffRepository.save(staff));
    }

    // Apply role, position and permissions
    private void applyRoleAndPermissions(Staff staff, StaffRequest request) {

        String role = request.getRole().toUpperCase().trim();

        if (!role.equals("ADMIN") && !role.equals("LIBRARIAN")) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Role must be ADMIN or LIBRARIAN");
        }

        staff.setRole(role);

        if (role.equals("ADMIN")) {
            staff.setPosition(null);
            staff.setPermissions(new HashSet<>());
            return;
        }

        staff.setPosition(request.getPosition() == null
                || request.getPosition().isBlank()
                        ? null
                        : request.getPosition().trim());

        Set<String> requestedCodes = request.getPermissions() == null
                ? new HashSet<>()
                : request.getPermissions();

        Set<Permission> permissions = new HashSet<>();

        for (String requestedCode : requestedCodes) {
            String code = requestedCode == null
                    ? ""
                    : requestedCode.trim().toUpperCase(Locale.ROOT);
            String description = PERMISSION_DESCRIPTIONS.get(code);
            if (description == null) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Unknown permission: " + requestedCode);
            }

            Permission permission = permissionRepository
                    .findByPermissionCode(code)
                    .orElseGet(() -> {
                        Permission newPermission = new Permission();
                        newPermission.setPermissionCode(code);
                        newPermission.setDescription(description);
                        return permissionRepository.save(newPermission);
                    });

            permissions.add(permission);
        }

        staff.setPermissions(permissions);
    }

    // Validate required information
    private void validateStaffRequest(StaffRequest request) {

        if (request.getFullName() == null
                || request.getFullName().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Full name is required");
        }

        if (request.getEmail() == null
                || request.getEmail().isBlank()
                || !request.getEmail().contains("@")) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "A valid email is required");
        }

        if (request.getRole() == null
                || request.getRole().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Role is required");
        }
    }

    // Convert Staff entity to StaffResponse DTO
    private StaffResponse convertToResponse(Staff staff) {

        StaffResponse response = new StaffResponse();

        response.setStaffId(staff.getStaffId());
        response.setFullName(staff.getFullName());
        response.setEmail(staff.getEmail());
        response.setPhoneNumber(staff.getPhoneNumber());
        response.setRole(staff.getRole());
        response.setPosition(staff.getPosition());
        response.setStatus(staff.getStatus());

        Set<String> permissionCodes = staff.getPermissions()
                .stream()
                .map(Permission::getPermissionCode)
                .collect(Collectors.toSet());

        response.setPermissions(permissionCodes);
        response.setCreatedAt(staff.getCreatedAt());
        response.setUpdatedAt(staff.getUpdatedAt());

        return response;
    }
}
