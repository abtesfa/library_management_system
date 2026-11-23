package com.library.library_backend.repository;

import com.library.library_backend.entity.Borrowing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
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
            bc.Location AS location
        FROM borrowing br
        JOIN book_copy bc ON br.Copy_ID = bc.Copy_ID
        JOIN book b ON bc.Book_ID = b.Book_ID
        WHERE br.User_ID = :userId
          AND UPPER(br.status) IN ('BORROWED', 'OVERDUE')
        ORDER BY br.Borrow_Date DESC
        """, nativeQuery = true)
    List<Object[]> findCurrentBorrowings(@Param("userId") Integer userId);

    @Query(value = "SELECT COUNT(*) > 0 FROM reservations r JOIN book_copy bc ON bc.Book_ID = r.Book_ID WHERE r.User_ID <> :userId AND bc.Copy_ID = :copyId AND r.Status IN ('WAITING','READY_FOR_PICKUP')", nativeQuery = true)
    boolean hasActiveReservationForBook(@Param("userId") Integer userId, @Param("copyId") Integer copyId);

    @Query(value = "SELECT br.Borrowing_ID, b.Title, b.ISBN, br.Borrow_Date, br.Original_Due_Date, br.Due_Date, br.Return_Date, br.Status, br.Renewal_Count, bc.Location, br.Fine_Amount FROM borrowing br JOIN book_copy bc ON br.Copy_ID=bc.Copy_ID JOIN book b ON bc.Book_ID=b.Book_ID WHERE br.User_ID=:userId AND UPPER(br.Status)='RETURNED' ORDER BY br.Return_Date DESC", nativeQuery = true)
    List<Object[]> findBorrowingHistory(@Param("userId") Integer userId);

    @Query(value = "SELECT br.Borrowing_ID, b.Title, b.ISBN, br.Borrow_Date, br.Original_Due_Date, br.Due_Date, br.Return_Date, br.Status, br.Renewal_Count, bc.Location, br.Fine_Amount FROM borrowing br JOIN book_copy bc ON br.Copy_ID=bc.Copy_ID JOIN book b ON bc.Book_ID=b.Book_ID WHERE br.User_ID=:userId AND UPPER(br.Status)='RETURNED' ORDER BY br.Return_Date DESC",
           countQuery = "SELECT COUNT(*) FROM borrowing br WHERE br.User_ID=:userId AND UPPER(br.Status)='RETURNED'",
           nativeQuery = true)
    Page<Object[]> findBorrowingHistoryPage(@Param("userId") Integer userId, Pageable pageable);
}