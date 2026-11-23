package com.library.library_backend.Controller;

import com.library.library_backend.Service.LibrarySettingsService;
import com.library.library_backend.entity.LibrarySettings;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class LibrarySettingsController {

    private final LibrarySettingsService settingsService;

    private static final String UPLOAD_DIRECTORY =
            "uploads/library-logo";

    private static final long MAX_FILE_SIZE =
            5 * 1024 * 1024; // 5 MB

    private static final Set<String> ALLOWED_CONTENT_TYPES =
            Set.of(
                    "image/png",
                    "image/jpeg",
                    "image/webp"
            );

    public LibrarySettingsController(
            LibrarySettingsService settingsService) {
        this.settingsService = settingsService;
    }

    // GET: Retrieve library settings
    @GetMapping
    public ResponseEntity<LibrarySettings> getSettings() {
        return ResponseEntity.ok(
                settingsService.getSettings()
        );
    }

    // PUT: Update library settings
    @PutMapping
    public ResponseEntity<LibrarySettings> updateSettings(
            @RequestBody LibrarySettings settings) {

        return ResponseEntity.ok(
                settingsService.updateSettings(settings)
        );
    }

    // POST: Upload library logo
    @PostMapping("/logo")
    public ResponseEntity<?> uploadLogo(
            @RequestParam("file") MultipartFile file) {

        try {

            // Check whether a file was selected
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body("Please select a logo image.");
            }

            // Check file size
            if (file.getSize() > MAX_FILE_SIZE) {
                return ResponseEntity.badRequest()
                        .body("Logo image must not exceed 5 MB.");
            }

            // Check image content type
            String contentType = file.getContentType();

            if (contentType == null ||
                    !ALLOWED_CONTENT_TYPES.contains(contentType)) {

                return ResponseEntity.badRequest()
                        .body("Only PNG, JPG, JPEG, and WebP images are allowed.");
            }

            // Create upload directory
            Path uploadPath = Paths.get(UPLOAD_DIRECTORY)
                    .toAbsolutePath()
                    .normalize();

            Files.createDirectories(uploadPath);

            // Generate a unique filename
            String extension;

            switch (contentType) {
                case "image/png":
                    extension = ".png";
                    break;
                case "image/webp":
                    extension = ".webp";
                    break;
                default:
                    extension = ".jpg";
                    break;
            }

            String filename = UUID.randomUUID() + extension;

            Path destination = uploadPath.resolve(filename)
                    .normalize();

            // Save image
            Files.copy(file.getInputStream(), destination);

            // Save relative URL in database
            String logoUrl = "/uploads/library-logo/" + filename;

          LibrarySettings updatedSettings =
        settingsService.updateLogo(logoUrl);

            return ResponseEntity.ok(updatedSettings);

        } catch (IOException e) {

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unable to upload library logo: " + e.getMessage());
        }
    }
}