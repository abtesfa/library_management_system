package com.library.library_backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.Author;

public interface AuthorRepository extends JpaRepository<Author, Integer> {

    /** Finds an author by name, ignoring upper/lower case. */
    Optional<Author> findByAuthorNameIgnoreCase(String authorName);
}
