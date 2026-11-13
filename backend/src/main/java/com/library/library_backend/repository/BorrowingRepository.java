package com.library.library_backend.repository;

import com.library.library_backend.entity.Borrowing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;

public interface BorrowingRepository
        extends JpaRepository<Borrowing, Integer> {

    @Query(value = """
        SELECT COUNT(*)
        FROM borrowing
        WHERE User_ID = :userId
        AND Status = 'BORROWED'
        """, nativeQuery = true)
    long countCurrentlyBorrowed(@Param("userId") Integer userId);

    @Query(value = """
        SELECT COUNT(*)
        FROM borrowing
        WHERE User_ID = :userId
        AND Status = 'BORROWED'
        AND Due_Date BETWEEN CURDATE()
        AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        """, nativeQuery = true)
    long countDueThisWeek(@Param("userId") Integer userId);

    @Query(value = """
        SELECT COUNT(*)
        FROM borrowing
        WHERE User_ID = :userId
        AND Status = 'RETURNED'
        AND Return_Date >= MAKEDATE(YEAR(CURDATE()), 1)
        AND Return_Date < MAKEDATE(YEAR(CURDATE()) + 1, 1)
        """, nativeQuery = true)

    long countBooksReadThisYear(@Param("userId") Integer userId);
    @Query(value = """
    SELECT COUNT(*)
    FROM borrowing
    WHERE User_ID = :userId
    AND Borrow_Date = :borrowDate
    """, nativeQuery = true)
long countBooksBorrowedOnDate(
        @Param("userId") Integer userId,
        @Param("borrowDate") java.time.LocalDate borrowDate
);
@Query(value = """
    SELECT b.Borrowing_ID
    FROM borrowing b
    JOIN student s ON s.User_ID = b.User_ID
    JOIN book_copy bc ON bc.Copy_ID = b.Copy_ID
    JOIN book bk ON bk.Book_ID = bc.Book_ID
    WHERE s.Student_ID = :studentId
      AND b.Status = 'BORROWED'
      AND (
          bk.isbn = :query
          OR bk.Title LIKE CONCAT('%', :query, '%')
      )
    ORDER BY b.Borrow_Date ASC
    LIMIT 1
    """, nativeQuery = true)
Optional<Integer> findActiveBorrowingId(
        @Param("studentId") String studentId,
        @Param("query") String query
);
}