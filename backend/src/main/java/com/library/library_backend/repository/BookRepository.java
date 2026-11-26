package com.library.library_backend.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Lock;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.book;

public interface BookRepository extends JpaRepository<book, Integer> {

  @Query(value = """
        SELECT *
        FROM book
        WHERE Book_ID = :bookId
        FOR UPDATE
        """, nativeQuery = true)
Optional<book> findByIdForUpdate(
        @Param("bookId") Integer bookId
);

    List<book> findByTitleContainingIgnoreCase(String keyword);

    Optional<book> findByIsbn(String isbn);

    @Modifying
    @Transactional
    @Query(value = "INSERT IGNORE INTO book_department (Book_ID, Department) VALUES (:bookId, :department)", nativeQuery = true)
    int addDepartmentMapping(@Param("bookId") Integer bookId, @Param("department") String department);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM book_department WHERE Book_ID=:bookId AND Department=:department", nativeQuery = true)
    int removeDepartmentMapping(@Param("bookId") Integer bookId, @Param("department") String department);

    @Query(value = "SELECT b.* FROM book b JOIN book_department bd ON bd.Book_ID=b.Book_ID WHERE LOWER(bd.Department)=LOWER(:department) ORDER BY b.Title", nativeQuery = true)
    List<book> findRecommendedForDepartment(@Param("department") String department);
}
