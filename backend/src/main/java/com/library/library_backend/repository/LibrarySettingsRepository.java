
package com.library.library_backend.repository;

import com.library.library_backend.entity.LibrarySettings;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LibrarySettingsRepository
        extends JpaRepository<LibrarySettings, Integer> {

    // Always retrieve the same canonical settings record.
    Optional<LibrarySettings> findFirstByOrderBySettingIdAsc();
}
