-- Preserve the configured value while correcting the setting's meaning.
-- Run once against an existing database before starting the updated backend.
ALTER TABLE library_settings
    CHANGE COLUMN max_books_per_day max_books_per_student INT NOT NULL;
