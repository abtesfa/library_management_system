package com.library.library_backend.repository;

import com.library.library_backend.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {

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