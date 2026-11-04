
package com.library.library_backend.Controller;

import com.library.library_backend.Service.LibrarySettingsService;
import com.library.library_backend.entity.LibrarySettings;

import org.springframework.http.ResponseEntity;
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
}

