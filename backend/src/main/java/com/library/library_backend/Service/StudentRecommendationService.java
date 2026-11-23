package com.library.library_backend.Service;

import com.library.library_backend.dto.BookResponse;
import com.library.library_backend.entity.Student;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.StudentRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class StudentRecommendationService {
    private final StudentRepository students;
    private final BookRepository books;
    private final BookService bookService;
    public StudentRecommendationService(StudentRepository students, BookRepository books, BookService bookService) {
        this.students = students; this.books = books; this.bookService = bookService;
    }
    public List<BookResponse> recommended(Integer userId, Integer categoryId) {
        Student student = students.findById(userId).orElseThrow(() -> new IllegalArgumentException("Student not found."));
        List<com.library.library_backend.entity.book> result;
        if (categoryId != null) result = books.findAll().stream().filter(b -> categoryId.equals(b.getCategoryId())).toList();
        else if (student.getDepartment() != null && !student.getDepartment().isBlank()) {
            result = books.findRecommendedForDepartment(student.getDepartment());
            if (result.isEmpty()) result = books.findAll();
        } else result = books.findAll();
        return result.stream().map(b -> bookService.getBookResponseById(b.getBookId())).toList();
    }
}
