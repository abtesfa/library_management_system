package com.library.library_backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.BookCopy;

public interface BookCopyRepository
        extends JpaRepository<BookCopy, Integer> {

    // Count all physical copies of a book
    long countByIsbn(String isbn);

    // Count copies with a particular status
    long countByIsbnAndStatus(String isbn, String status);

    // Find the first available copy
    Optional<BookCopy> findFirstByIsbnAndStatus(
            String isbn, String status
    );

    // Find the first copy regardless of status
    Optional<BookCopy> findFirstByIsbn(String isbn);
}