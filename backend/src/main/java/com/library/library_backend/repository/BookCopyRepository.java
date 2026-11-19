
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

    long countByBookId(Integer bookId);

    long countByBookIdAndStatus(Integer bookId, String status);

    Optional<BookCopy> findFirstByBookIdAndStatus(
            Integer bookId,
            String status
    );

    Optional<BookCopy> findFirstByBookId(Integer bookId);

    List<BookCopy> findAllByBookId(Integer bookId);

    List<BookCopy> findAllByBookIdAndStatusOrderByCopyIdAsc(
            Integer bookId,
            String status
    );

    @Modifying
    @Query("""
        UPDATE BookCopy copy
        SET copy.location = :location
        WHERE copy.bookId = :bookId
        """)
    int updateLocationByBookId(
            @Param("bookId") Integer bookId,
            @Param("location") String location
    );
}
