package com.library.library_backend.repository;

import com.library.library_backend.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {

   Optional<Student> findByEmailIgnoreCase(String email);

   @Query(value = "SELECT COUNT(*) FROM borrowing WHERE User_ID = :userId AND UPPER(Status) IN ('BORROWED','OVERDUE') AND Return_Date IS NULL", nativeQuery = true)
   long countActiveLoans(@Param("userId") Integer userId);

   Optional<Student> findByStudentId(String studentId);

  @Query(value = """
        SELECT *
        FROM student
        WHERE user_id = :userId
        FOR UPDATE
        """, nativeQuery = true)
Optional<Student> findByIdForUpdate(
        @Param("userId") Integer userId
);


@Query(value = """
        SELECT *
        FROM student
        WHERE student_id = :studentId
        FOR UPDATE
        """, nativeQuery = true)
Optional<Student> findByStudentIdForUpdate(
        @Param("studentId") String studentId
);
   @Query(value = """
    SELECT User_ID
    FROM student
    WHERE Student_ID = :studentId
    LIMIT 1
    """, nativeQuery = true)
Optional<Integer> findUserIdByStudentId(
    @Param("studentId") String studentId
);
}