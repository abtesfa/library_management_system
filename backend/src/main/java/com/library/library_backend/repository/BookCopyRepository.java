package com.library.library_backend.repository;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    List<BookCopy> findAllByBookId(Integer bookId);

    @Modifying
    @Query("""
        UPDATE BookCopy copy
        SET copy.location = :location
        WHERE copy.bookId = :bookId
        """)
    int updateLocationByBookId(
            @Param("bookId") Integer bookId,
            @Param("location") String location);
}
