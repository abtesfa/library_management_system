package com.library.library_backend.Service;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.Iterator;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

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

    private static final int MAX_PROFILE_PHOTO_BYTES = 5 * 1024 * 1024;
    private static final int MAX_PROFILE_PHOTO_DIMENSION = 4096;
    private static final long MAX_PROFILE_PHOTO_PIXELS = 16_777_216L;

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

        if ("STUDENT".equals(role)) {
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

        if ("STUDENT".equals(normalizedRole)) {
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

    public void updateProfilePhoto(
            String accountId,
            String role,
            String encodedPhoto) {
        if (accountId == null || accountId.isBlank()) {
            throw invalidCredentials();
        }

        int parsedAccountId;
        try {
            parsedAccountId = Integer.parseInt(accountId.trim());
        } catch (NumberFormatException exception) {
            throw invalidCredentials();
        }

        byte[] photo = decodeProfilePhoto(encodedPhoto);
        String normalizedRole = role == null
                ? ""
                : role.trim().toUpperCase(Locale.ROOT);

        if ("STUDENT".equals(normalizedRole)) {
            Student account = studentRepository.findById(parsedAccountId)
                    .orElseThrow(this::invalidCredentials);
            if (!"ACTIVE".equalsIgnoreCase(account.getStatus())) {
                throw invalidCredentials();
            }

            account.setProfilePhoto(photo);
            studentRepository.save(account);
            return;
        }

        if ("ADMIN".equals(normalizedRole)
                || "LIBRARIAN".equals(normalizedRole)) {
            Staff account = staffRepository.findById(parsedAccountId)
                    .orElseThrow(this::invalidCredentials);
            if (!normalizedRole.equalsIgnoreCase(account.getRole())
                    || !"ACTIVE".equalsIgnoreCase(account.getStatus())) {
                throw invalidCredentials();
            }

            account.setProfilePhoto(photo);
            staffRepository.save(account);
            return;
        }

        throw invalidCredentials();
    }

    private byte[] decodeProfilePhoto(String encodedPhoto) {
        if (encodedPhoto == null || encodedPhoto.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Choose a profile photo first.");
        }

        byte[] photo;
        try {
            photo = Base64.getDecoder().decode(encodedPhoto);
        } catch (IllegalArgumentException exception) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "The profile photo data is invalid.");
        }

        if (photo.length == 0 || photo.length > MAX_PROFILE_PHOTO_BYTES) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Profile photos must be smaller than 5 MB.");
        }

        try (ImageInputStream input = ImageIO.createImageInputStream(
                new ByteArrayInputStream(photo))) {
            if (input == null) {
                throw invalidProfilePhoto();
            }

            Iterator<ImageReader> readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) {
                throw invalidProfilePhoto();
            }

            ImageReader reader = readers.next();
            try {
                reader.setInput(input, true, true);
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width < 1
                        || height < 1
                        || width > MAX_PROFILE_PHOTO_DIMENSION
                        || height > MAX_PROFILE_PHOTO_DIMENSION
                        || (long) width * height > MAX_PROFILE_PHOTO_PIXELS) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "Profile photo dimensions are too large.");
                }

                BufferedImage decoded = reader.read(0);
                if (decoded == null) {
                    throw invalidProfilePhoto();
                }
            } finally {
                reader.dispose();
            }
        } catch (IOException exception) {
            throw invalidProfilePhoto();
        }

        return photo;
    }

    private ResponseStatusException invalidProfilePhoto() {
        return new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Choose a valid image file for your profile photo.");
    }

    private LoginResponse loginStudent(String identifier, String password) {
        Optional<Student> student = studentRepository.findByStudentId(identifier);
        if (student.isEmpty()) {
            student = studentRepository.findByEmailIgnoreCase(identifier);
        }

        Student account = student.orElseThrow(this::invalidCredentials);
        if (!"ACTIVE".equalsIgnoreCase(account.getStatus())
                || !matchesAndUpgradeStudentPassword(account, password)) {
            throw invalidCredentials();
        }

        return new LoginResponse(
                account.getUserId().toString(),
                account.getFullName(),
                account.getEmail(),
                "STUDENT",
                account.getDepartment(),
                account.isMustChangePassword(),
                Set.of(),
                account.getProfilePhoto());
    }

    private boolean matchesAndUpgradeStudentPassword(
            Student account,
            String password) {
        String storedPassword = account.getPassword();
        if (passwordHashService.isEncoded(storedPassword)) {
            return passwordHashService.matches(password, storedPassword);
        }

        if (storedPassword == null
                || !MessageDigest.isEqual(
                        password.getBytes(StandardCharsets.UTF_8),
                        storedPassword.getBytes(StandardCharsets.UTF_8))) {
            return false;
        }

        account.setPassword(passwordHashService.hash(password));
        studentRepository.save(account);
        return true;
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
                        .collect(Collectors.toSet()),
                account.getProfilePhoto());
    }

    private ResponseStatusException invalidCredentials() {
        return new ResponseStatusException(
                HttpStatus.UNAUTHORIZED,
                "Invalid credentials or account role");
    }
}
