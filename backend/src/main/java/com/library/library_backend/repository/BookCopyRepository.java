package com.library.library_backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.BookCopy;

public interface BookCopyRepository
        extends JpaRepository<BookCopy, Integer> {

    // Count all physical copies of a book
    long countByBookId(Integer bookId);

    // Count copies with a particular status
    long countByBookIdAndStatus(Integer bookId, String status);

    // Find the first copy with a particular status
    Optional<BookCopy> findFirstByBookIdAndStatus(
            Integer bookId, String status
    );

    // Find the first copy regardless of status
    Optional<BookCopy> findFirstByBookId(Integer bookId);
}
