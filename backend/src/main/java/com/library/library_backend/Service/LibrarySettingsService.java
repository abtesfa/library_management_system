
package com.library.library_backend.Service;

import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.repository.LibrarySettingsRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class LibrarySettingsService {

    private final LibrarySettingsRepository repository;

    public LibrarySettingsService(LibrarySettingsRepository repository) {
        this.repository = repository;
    }

    // Get library settings
    public LibrarySettings getSettings() {

        List<LibrarySettings> settings = repository.findAll();

        if (settings.isEmpty()) {
            throw new RuntimeException(
                "Library settings have not been configured."
            );
        }

        return settings.get(0);
    }

    // Update ordinary library settings
    @Transactional
    public LibrarySettings updateSettings(LibrarySettings updatedSettings) {

        LibrarySettings existingSettings = getSettings();

        if (updatedSettings.getLibraryName() == null ||
                updatedSettings.getLibraryName().isBlank()) {
            throw new IllegalArgumentException(
                "Library name cannot be empty."
            );
        }

        if (updatedSettings.getMaxBooksPerStudent() == null ||
                updatedSettings.getMaxBooksPerStudent() < 1) {
            throw new IllegalArgumentException(
                "Maximum books per student must be at least 1."
            );
        }

        if (updatedSettings.getMaxBorrowingDays() == null ||
                updatedSettings.getMaxBorrowingDays() < 1) {
            throw new IllegalArgumentException(
                "Maximum borrowing days must be at least 1."
            );
        }

        if (updatedSettings.getRenewalLimit() == null ||
                updatedSettings.getRenewalLimit() < 0) {
            throw new IllegalArgumentException(
                "Renewal limit cannot be negative."
            );
        }

        BigDecimal fine = updatedSettings.getFinePerDay();

        if (fine == null || fine.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException(
                "Fine per day cannot be negative."
            );
        }

        Integer reservationHoldMinutes =
            updatedSettings.getReservationHoldMinutes();

        if (reservationHoldMinutes == null ||
                reservationHoldMinutes < 1) {
            throw new IllegalArgumentException(
                "Reservation pickup time limit must be at least one minute."
            );
        }

        // Update library name
        existingSettings.setLibraryName(
            updatedSettings.getLibraryName().trim()
        );

        // Update circulation policies
        existingSettings.setMaxBooksPerStudent(
            updatedSettings.getMaxBooksPerStudent()
        );

        existingSettings.setMaxBorrowingDays(
            updatedSettings.getMaxBorrowingDays()
        );

        existingSettings.setRenewalLimit(
            updatedSettings.getRenewalLimit()
        );

        existingSettings.setFinePerDay(fine);

        existingSettings.setReservationHoldMinutes(
            reservationHoldMinutes
        );

        // Update library email when provided
        if (updatedSettings.getContactEmail() != null) {
            existingSettings.setContactEmail(
                updatedSettings.getContactEmail().trim()
            );
        }

        // Update library address when provided
        if (updatedSettings.getLibraryAddress() != null) {
            existingSettings.setLibraryAddress(
                updatedSettings.getLibraryAddress().trim()
            );
        }

        // Preserve the existing logo URL.
        return repository.save(existingSettings);
    }

    // Update library logo separately
    @Transactional
    public LibrarySettings updateLogo(String logoUrl) {

        if (logoUrl == null || logoUrl.isBlank()) {
            throw new IllegalArgumentException(
                "Logo URL cannot be empty."
            );
        }

        LibrarySettings existingSettings = getSettings();

        existingSettings.setLogoUrl(logoUrl);

        return repository.save(existingSettings);
    }

    // Get reservation hold time
    public int getReservationHoldMinutes() {

        Integer minutes = getSettings().getReservationHoldMinutes();

        if (minutes == null || minutes < 1) {
            throw new IllegalStateException(
                "Reservation pickup time limit is not configured correctly."
            );
        }

        return minutes;
    }
}
