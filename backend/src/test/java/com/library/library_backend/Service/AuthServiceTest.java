package com.library.library_backend.Service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

import com.library.library_backend.dto.LoginRequest;
import com.library.library_backend.dto.LoginResponse;
import com.library.library_backend.entity.Staff;
import com.library.library_backend.entity.Student;
import com.library.library_backend.repository.StaffRepository;
import com.library.library_backend.repository.StudentRepository;
import com.library.library_backend.security.PasswordHashService;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private StaffRepository staffRepository;

    @Mock
    private StudentRepository studentRepository;

    private PasswordHashService passwordHashService;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        passwordHashService = new PasswordHashService();
        authService = new AuthService(
                staffRepository,
                studentRepository,
                passwordHashService);
    }

    @Test
    void logsInStudentByStudentIdAndReturnsDatabaseUserId() {
        Student student = new Student();
        student.setUserId(42);
        student.setStudentId("ST-42");
        student.setFullName("Test Student");
        student.setEmail("student@example.com");
        student.setDepartment("Science");
        student.setStatus("ACTIVE");
        student.setPassword(passwordHashService.hash("student-pass"));

        when(studentRepository.findByStudentId("ST-42"))
                .thenReturn(Optional.of(student));

        LoginResponse response = authService.login(
                loginRequest("ST-42", "student-pass", "STUDENT"));

        assertEquals("42", response.accountId());
        assertEquals("STUDENT", response.role());
        assertEquals("Test Student", response.fullName());
        verify(studentRepository).findByStudentId("ST-42");
    }

    @Test
    void verifiesStaffPasswordAndSelectedRole() {
        Staff staff = new Staff();
        staff.setStaffId(9);
        staff.setFullName("Test Librarian");
        staff.setEmail("librarian@example.com");
        staff.setRole("LIBRARIAN");
        staff.setPosition("Reference Librarian");
        staff.setStatus("ACTIVE");
        staff.setPasswordHash(passwordHashService.hash("staff-pass"));

        when(staffRepository.findByEmailIgnoreCase("librarian@example.com"))
                .thenReturn(Optional.of(staff));

        LoginResponse response = authService.login(
                loginRequest(
                        "librarian@example.com",
                        "staff-pass",
                        "LIBRARIAN"));

        assertEquals("9", response.accountId());
        assertEquals("LIBRARIAN", response.role());
    }

    @Test
    void rejectsWrongPasswordOrRole() {
        Staff staff = new Staff();
        staff.setEmail("admin@example.com");
        staff.setRole("ADMIN");
        staff.setStatus("ACTIVE");
        staff.setPasswordHash(passwordHashService.hash("correct-pass"));

        when(staffRepository.findByEmailIgnoreCase("admin@example.com"))
                .thenReturn(Optional.of(staff));

        assertThrows(
                ResponseStatusException.class,
                () -> authService.login(
                        loginRequest(
                                "admin@example.com",
                                "wrong-pass",
                                "ADMIN")));
        assertThrows(
                ResponseStatusException.class,
                () -> authService.login(
                        loginRequest(
                                "admin@example.com",
                                "correct-pass",
                                "LIBRARIAN")));
    }

    @Test
    void allowsStaffToLoginWithTemporaryPasswordAndRequiresPasswordChange() {
        Staff staff = new Staff();
        staff.setStaffId(13);
        staff.setFullName("Temp Staff");
        staff.setEmail("temp.staff@example.com");
        staff.setRole("LIBRARIAN");
        staff.setPosition("Reference Librarian");
        staff.setStatus("ACTIVE");
        staff.setMustChangePassword(true);
        staff.setPasswordHash(passwordHashService.hash("temp-pass-123"));

        when(staffRepository.findByEmailIgnoreCase("temp.staff@example.com"))
                .thenReturn(Optional.of(staff));

        LoginResponse response = authService.login(
                loginRequest(
                        "temp.staff@example.com",
                        "temp-pass-123",
                        "LIBRARIAN"));

        assertEquals("13", response.accountId());
        assertEquals(true, response.requiresPasswordChange());
    }

    @Test
    void allowsStudentToLoginWithStudentIdAndTemporaryPassword() {
        Student student = new Student();
        student.setUserId(77);
        student.setStudentId("ST-77");
        student.setFullName("Temp Reader");
        student.setEmail("reader77@example.com");
        student.setDepartment("Computer Science");
        student.setStatus("ACTIVE");
        student.setMustChangePassword(true);
        student.setPassword(passwordHashService.hash("temp-reader-123"));

        when(studentRepository.findByStudentId("ST-77"))
                .thenReturn(Optional.of(student));

        LoginResponse response = authService.login(
                loginRequest(
                        "ST-77",
                        "temp-reader-123",
                        "STUDENT"));

        assertEquals("77", response.accountId());
        assertEquals("STUDENT", response.role());
        assertEquals(true, response.requiresPasswordChange());
    }

    private LoginRequest loginRequest(
            String identifier,
            String password,
            String role) {
        LoginRequest request = new LoginRequest();
        request.setIdentifier(identifier);
        request.setPassword(password);
        request.setRole(role);
        return request;
    }
}
