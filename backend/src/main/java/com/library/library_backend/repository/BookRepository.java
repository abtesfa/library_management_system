
package com.library.library_backend.repository;

import java.util.Optional;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.library.library_backend.entity.book;
import java.util.List;

public interface BookRepository extends JpaRepository<book, Integer> {

    @Query(value = """
            SELECT b.*
            FROM book b
            LEFT JOIN author a ON a.Author_ID = b.Author_ID
            LEFT JOIN category c ON c.Category_ID = b.Category_ID
            WHERE (
                :keyword IS NULL
                OR :keyword = ''
                OR LOWER(COALESCE(b.Title, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
                OR LOWER(COALESCE(a.Author_Name, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
                OR LOWER(COALESCE(c.Category_Name, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
            )
            ORDER BY b.Book_ID ASC
            """, countQuery = """
            SELECT COUNT(*)
            FROM book b
            LEFT JOIN author a ON a.Author_ID = b.Author_ID
            LEFT JOIN category c ON c.Category_ID = b.Category_ID
            WHERE (
                :keyword IS NULL
                OR :keyword = ''
                OR LOWER(COALESCE(b.Title, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
                OR LOWER(COALESCE(a.Author_Name, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
                OR LOWER(COALESCE(c.Category_Name, ''))
                    LIKE CONCAT('%', LOWER(:keyword), '%')
            )
            """, nativeQuery = true)
    Page<book> searchCatalogue(
            @Param("keyword") String keyword,
            Pageable pageable);


    /** Serializes reservation/checkout allocation for one book. */
    @Query(value = "SELECT * FROM book WHERE book_id = :bookId FOR UPDATE", nativeQuery = true)
    Optional<book> findByIdForUpdate(@Param("bookId") Integer bookId);

    Optional<book> findByIsbn(String isbn);

    List<book> findByTitleContainingIgnoreCase(String keyword);
}
