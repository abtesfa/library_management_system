package com.library.library_backend.repository;

import com.library.library_backend.entity.Borrowing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


import java.util.List;


public interface MyBooksRepository extends JpaRepository<Borrowing, Integer> {

    @Query(value = """
    SELECT
        br.Borrowing_ID AS borrowingId,
        b.Title AS bookTitle,
        b.ISBN AS isbn,
        br.Borrow_Date AS borrowDate,
        br.Due_Date AS dueDate,
        br.Return_Date AS returnDate,
        br.status AS status,
        br.Renewal_Count AS renewalCount,
        bc.Location AS location,
        b.cover_image AS coverImage,
        bc.Book_ID AS bookId
    FROM borrowing br
    JOIN book_copy bc ON br.Copy_ID = bc.Copy_ID
    JOIN book b ON bc.Book_ID = b.Book_ID
    WHERE br.User_ID = :userId
      AND UPPER(br.status) IN ('BORROWED', 'OVERDUE')
    ORDER BY br.Borrow_Date DESC
    """, nativeQuery = true)
    List<Object[]> findCurrentBorrowings(@Param("userId") Integer userId);

    @Query(value = """
    SELECT
        br.Borrowing_ID AS borrowingId,
        b.Title AS bookTitle,
        b.ISBN AS isbn,
        br.Borrow_Date AS borrowDate,
        br.Due_Date AS dueDate,
        br.Return_Date AS returnDate,
        br.Status AS status,
        br.Renewal_Count AS renewalCount,
        bc.Location AS location,
        b.cover_image AS coverImage
    FROM borrowing br
    JOIN book_copy bc ON br.Copy_ID = bc.Copy_ID
    JOIN book b ON bc.Book_ID = b.Book_ID
    WHERE br.User_ID = ?1
      AND UPPER(br.Status) = 'RETURNED'
    ORDER BY
        br.Return_Date DESC,
        br.Borrow_Date DESC,
        br.Borrowing_ID DESC
    LIMIT ?2 OFFSET ?3
    """, nativeQuery = true)
List<Object[]> findReturnedBorrowings(
        @Param("userId") Integer userId,
        @Param("limit") int limit,
        @Param("offset") int offset
);
}