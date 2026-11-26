
package com.library.library_backend.Controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.library.library_backend.Service.LibrarySettingsService;
import com.library.library_backend.entity.LibrarySettings;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class LibrarySettingsController {

    private final LibrarySettingsService settingsService;

    @Value("${library.upload-dir}")
    private String uploadDirectory;

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;

    public LibrarySettingsController(
            LibrarySettingsService settingsService) {
        this.settingsService = settingsService;
    }

    @GetMapping
    public ResponseEntity<LibrarySettings> getSettings() {
        return ResponseEntity.ok(settingsService.getSettings());
    }

    @PutMapping
    public ResponseEntity<LibrarySettings> updateSettings(
            @RequestBody LibrarySettings settings) {

        return ResponseEntity.ok(
                settingsService.updateSettings(settings)
        );
    }

    @PostMapping("/logo")
    public ResponseEntity<?> uploadLogo(
            @RequestParam("file") MultipartFile file) {

        try {
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body("Please select a logo image.");
            }

            if (file.getSize() > MAX_FILE_SIZE) {
                return ResponseEntity.badRequest()
                        .body("Logo image must not exceed 10 MB.");
            }

            byte[] imageBytes = file.getBytes();
            String extension = detectImageExtension(imageBytes);

            if (extension == null) {
                return ResponseEntity.badRequest()
                        .body("Invalid image. Only PNG, JPG, JPEG, and WebP images are allowed.");
            }

            // Use permanent configured storage directory
            Path uploadPath = Paths.get(uploadDirectory)
                    .toAbsolutePath()
                    .normalize();

            Files.createDirectories(uploadPath);

            // Generate unique filename
            String filename = UUID.randomUUID() + extension;

            Path destination = uploadPath.resolve(filename)
                    .normalize();

            if (!destination.startsWith(uploadPath)) {
                return ResponseEntity.badRequest()
                        .body("Invalid file destination.");
            }

            // Save actual image
            Files.write(destination, imageBytes);

            // Save image URL in database
            String logoUrl = "/uploads/library-logo/" + filename;

            LibrarySettings updatedSettings =
                    settingsService.updateLogo(logoUrl);

            return ResponseEntity.ok(updatedSettings);

        } catch (IOException e) {
            return ResponseEntity.status(
                    HttpStatus.INTERNAL_SERVER_ERROR
            ).body("Unable to upload library logo: " + e.getMessage());
        }
    }

    private String detectImageExtension(byte[] bytes) {

        if (bytes == null || bytes.length < 12) {
            return null;
        }

        // PNG
        if ((bytes[0] & 0xFF) == 0x89 &&
                bytes[1] == 0x50 &&
                bytes[2] == 0x4E &&
                bytes[3] == 0x47 &&
                bytes[4] == 0x0D &&
                bytes[5] == 0x0A &&
                bytes[6] == 0x1A &&
                bytes[7] == 0x0A) {
            return ".png";
        }

        // JPEG
        if ((bytes[0] & 0xFF) == 0xFF &&
                (bytes[1] & 0xFF) == 0xD8 &&
                (bytes[2] & 0xFF) == 0xFF) {
            return ".jpg";
        }

        // WebP
        if (bytes[0] == 'R' &&
                bytes[1] == 'I' &&
                bytes[2] == 'F' &&
                bytes[3] == 'F' &&
                bytes[8] == 'W' &&
                bytes[9] == 'E' &&
                bytes[10] == 'B' &&
                bytes[11] == 'P') {
            return ".webp";
        }

        return null;
    }
}
