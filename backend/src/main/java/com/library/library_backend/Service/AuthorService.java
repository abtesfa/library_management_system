package com.library.library_backend.Service;

import com.library.library_backend.dto.AuthorBooksResponse;
import com.library.library_backend.entity.Author;
import com.library.library_backend.repository.AuthorRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthorService {

    private final AuthorRepository authorRepository;

    public AuthorService(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
    }

    public AuthorBooksResponse getAuthorBooks(Integer authorId) {

        Author author = authorRepository
                .findWithBooksByAuthorId(authorId)
                .orElseThrow(() ->
                    new RuntimeException("Author not found: " + authorId)
                );

        return new AuthorBooksResponse(
                author.getAuthorId(),
                author.getAuthorName(),
                author.getBooks()
                        .stream()
                        .map(book -> book.getTitle())
                        .toList()
        );
    }
}