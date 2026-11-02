package com.library.library_backend.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateBookRequest {
    @NotBlank(message = "Title is required")
    private String title;

    private String isbn;

    @NotBlank(message = "Author name is required")
    private String author;

    @NotBlank(message = "Category name is required")
    private String category;

    private String publisher; // Optional text name

    private Integer authorId;
    private Integer categoryId;
    private Integer publisherId;

    private int totalCopies = 1;
    private String location;

    public CreateBookRequest() {}

    // Getters and Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public Integer getAuthorId() { return authorId; }
    public void setAuthorId(Integer authorId) { this.authorId = authorId; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public Integer getPublisherId() { return publisherId; }
    public void setPublisherId(Integer publisherId) { this.publisherId = publisherId; }

    public int getTotalCopies() { return totalCopies; }
    public void setTotalCopies(int totalCopies) { this.totalCopies = totalCopies; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
}