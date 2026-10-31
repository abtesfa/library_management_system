package com.library.library_backend.dto;

import java.util.List;

public class AuthorBooksResponse {

    private Integer authorId;
    private String authorName;
    private List<String> books;

    public AuthorBooksResponse(
            Integer authorId,
            String authorName,
            List<String> books) {

        this.authorId = authorId;
        this.authorName = authorName;
        this.books = books;
    }

    public Integer getAuthorId() {
        return authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public List<String> getBooks() {
        return books;
    }
}