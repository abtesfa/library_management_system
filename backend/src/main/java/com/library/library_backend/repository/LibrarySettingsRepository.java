
package com.library.library_backend.repository;

import com.library.library_backend.entity.LibrarySettings;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LibrarySettingsRepository
        extends JpaRepository<LibrarySettings, Integer> {
}
