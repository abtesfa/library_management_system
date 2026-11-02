package com.library.library_backend.repository;

import com.library.library_backend.entity.Author;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface AuthorRepository extends JpaRepository<Author, Integer> {
        Optional<Author> findByAuthorName(String authorName);
}