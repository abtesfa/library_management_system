package com.library.library_backend.Service;

import com.library.library_backend.dto.StudentDashboardResponse;
import com.library.library_backend.entity.Student;
import com.library.library_backend.repository.StudentRepository;
import com.library.library_backend.repository.BorrowingRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class StudentDashboardService {

    private final StudentRepository studentRepository;
    private final BorrowingRepository borrowingRepository;

    public StudentDashboardService(
            StudentRepository studentRepository,
            BorrowingRepository borrowingRepository) {

        this.studentRepository = studentRepository;
        this.borrowingRepository = borrowingRepository;
    }

    public StudentDashboardResponse getDashboard(Integer userId) {

        Student student = studentRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Student not found"
                ));

        if (!"ACTIVE".equals(student.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Student account is not active"
            );
        }

        long currentlyBorrowed =
                borrowingRepository.countCurrentlyBorrowed(userId);

        long dueThisWeek =
                borrowingRepository.countDueThisWeek(userId);

        long booksReadThisYear =
                borrowingRepository.countBooksReadThisYear(userId);

        return new StudentDashboardResponse(
                student.getFullName(),
                currentlyBorrowed,
                dueThisWeek,
                booksReadThisYear
        );
    }
}