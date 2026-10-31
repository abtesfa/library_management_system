
package com.library.library_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.Author;
import org.springframework.data.jpa.repository.EntityGraph;
import java.util.Optional;

public interface AuthorRepository
        extends JpaRepository<Author, Integer> {
                @EntityGraph(attributePaths = "books")
Optional<Author> findWithBooksByAuthorId(Integer authorId);
}
