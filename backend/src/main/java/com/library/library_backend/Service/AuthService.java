package com.library.library_backend.Service;

import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.library.library_backend.dto.LoginRequest;
import com.library.library_backend.dto.LoginResponse;
import com.library.library_backend.entity.Staff;
import com.library.library_backend.entity.Student;
import com.library.library_backend.repository.StaffRepository;
import com.library.library_backend.repository.StudentRepository;
import com.library.library_backend.security.PasswordHashService;

@Service
public class AuthService {

    private final StaffRepository staffRepository;
    private final StudentRepository studentRepository;
    private final PasswordHashService passwordHashService;

    public AuthService(
            StaffRepository staffRepository,
            StudentRepository studentRepository,
            PasswordHashService passwordHashService) {
        this.staffRepository = staffRepository;
        this.studentRepository = studentRepository;
        this.passwordHashService = passwordHashService;
    }

    public LoginResponse login(LoginRequest request) {
        if (request.getIdentifier() == null
                || request.getIdentifier().isBlank()
                || request.getPassword() == null
                || request.getPassword().isEmpty()
                || request.getRole() == null
                || request.getRole().isBlank()) {
            throw invalidCredentials();
        }

        String identifier = request.getIdentifier().trim();
        String role = request.getRole().trim().toUpperCase(Locale.ROOT);

        if ("STUDENT".equals(role) || "READER".equals(role)) {
            return loginStudent(identifier, request.getPassword());
        }

        if ("ADMIN".equals(role) || "LIBRARIAN".equals(role)) {
            return loginStaff(identifier, role, request.getPassword());
        }

        throw invalidCredentials();
    }

    public void changePassword(
            String identifier,
            String role,
            String currentPassword,
            String newPassword) {
        if (identifier == null || identifier.isBlank()
                || currentPassword == null || currentPassword.isBlank()
                || newPassword == null || newPassword.isBlank()) {
            throw invalidCredentials();
        }

        if (newPassword.length() < 8) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Password must be at least 8 characters");
        }

        String normalizedRole = role == null ? "" : role.trim().toUpperCase(Locale.ROOT);

        if ("STUDENT".equals(normalizedRole) || "READER".equals(normalizedRole)) {
            Student account = studentRepository.findByStudentId(identifier)
                    .or(() -> studentRepository.findByEmailIgnoreCase(identifier))
                    .orElseThrow(this::invalidCredentials);

            if (!"ACTIVE".equalsIgnoreCase(account.getStatus())
                    || !passwordHashService.matches(
                            currentPassword,
                            account.getPassword())) {
                throw invalidCredentials();
            }

            account.setPassword(passwordHashService.hash(newPassword));
            account.setMustChangePassword(false);
            studentRepository.save(account);
            return;
        }

        if ("ADMIN".equals(normalizedRole) || "LIBRARIAN".equals(normalizedRole)) {
            Staff account = staffRepository
                    .findByEmailIgnoreCase(identifier.toLowerCase(Locale.ROOT))
                    .orElseThrow(this::invalidCredentials);

            if (!normalizedRole.equalsIgnoreCase(account.getRole())
                    || !"ACTIVE".equalsIgnoreCase(account.getStatus())
                    || !passwordHashService.matches(
                            currentPassword,
                            account.getPasswordHash())) {
                throw invalidCredentials();
            }

            account.setPasswordHash(passwordHashService.hash(newPassword));
            account.setMustChangePassword(false);
            staffRepository.save(account);
            return;
        }

        throw invalidCredentials();
    }

    private LoginResponse loginStudent(String identifier, String password) {
        Optional<Student> student = studentRepository.findByStudentId(identifier);
        if (student.isEmpty()) {
            student = studentRepository.findByEmailIgnoreCase(identifier);
        }

        Student account = student.orElseThrow(this::invalidCredentials);
        if (!"ACTIVE".equalsIgnoreCase(account.getStatus())
                || !passwordHashService.matches(
                        password,
                        account.getPassword())) {
            throw invalidCredentials();
        }

        return new LoginResponse(
                account.getUserId().toString(),
                account.getFullName(),
                account.getEmail(),
                "STUDENT",
                account.getDepartment(),
                account.isMustChangePassword(),
                Set.of());
    }

    private LoginResponse loginStaff(
            String identifier,
            String requestedRole,
            String password) {
        Staff account = staffRepository
                .findByEmailIgnoreCase(identifier.toLowerCase(Locale.ROOT))
                .orElseThrow(this::invalidCredentials);

        if (!requestedRole.equalsIgnoreCase(account.getRole())
                || !"ACTIVE".equalsIgnoreCase(account.getStatus())
                || !passwordHashService.matches(
                        password,
                        account.getPasswordHash())) {
            throw invalidCredentials();
        }

        return new LoginResponse(
                account.getStaffId().toString(),
                account.getFullName(),
                account.getEmail(),
                account.getRole().toUpperCase(Locale.ROOT),
                account.getPosition(),
                account.isMustChangePassword(),
                account.getPermissions().stream()
                        .map(permission -> permission.getPermissionCode())
                        .collect(Collectors.toSet()));
    }

    private ResponseStatusException invalidCredentials() {
        return new ResponseStatusException(
                HttpStatus.UNAUTHORIZED,
                "Invalid credentials or account role");
    }
}
