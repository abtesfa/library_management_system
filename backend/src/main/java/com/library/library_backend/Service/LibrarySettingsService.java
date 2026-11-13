
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

    // Get the library settings
    public LibrarySettings getSettings() {
        List<LibrarySettings> settings = repository.findAll();

        if (settings.isEmpty()) {
            throw new RuntimeException(
                "Library settings have not been configured."
            );
        }

        return settings.get(0);
    }

    // Update the library settings
    @Transactional
    public LibrarySettings updateSettings(LibrarySettings updatedSettings) {

        LibrarySettings existingSettings = getSettings();

        if (updatedSettings.getLibraryName() == null ||
                updatedSettings.getLibraryName().isBlank()) {
            throw new IllegalArgumentException(
                "Library name cannot be empty."
            );
        }

        if (updatedSettings.getMaxBooksPerDay() == null ||
                updatedSettings.getMaxBooksPerDay() < 1) {
            throw new IllegalArgumentException(
                "Maximum books per day must be at least 1."
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
        if (reservationHoldMinutes == null || reservationHoldMinutes < 1) {
            throw new IllegalArgumentException(
                "Reservation pickup time limit must be at least one minute."
            );
        }

        existingSettings.setLibraryName(
            updatedSettings.getLibraryName().trim()
        );

        existingSettings.setMaxBooksPerDay(
            updatedSettings.getMaxBooksPerDay()
        );

        existingSettings.setMaxBorrowingDays(
            updatedSettings.getMaxBorrowingDays()
        );

        existingSettings.setRenewalLimit(
            updatedSettings.getRenewalLimit()
        );

        existingSettings.setFinePerDay(fine);
        existingSettings.setReservationHoldMinutes(reservationHoldMinutes);

        return repository.save(existingSettings);
    }

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
