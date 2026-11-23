
package com.library.library_backend.Controller;

import com.library.library_backend.Service.LibrarySettingsService;
import com.library.library_backend.entity.LibrarySettings;

import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class LibrarySettingsController {

    private final LibrarySettingsService settingsService;

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
    @PutMapping(value = "/logo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Void> uploadLogo(@RequestPart("file") MultipartFile file) throws Exception {
        settingsService.updateLogo(file);
        return ResponseEntity.noContent().build();
    }

    @GetMapping(value = "/logo", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> getLogo() {
        byte[] logo = settingsService.getLogo();
        return logo == null ? ResponseEntity.notFound().build() : ResponseEntity.ok().contentType(MediaType.APPLICATION_OCTET_STREAM).body(logo);
    }
}

