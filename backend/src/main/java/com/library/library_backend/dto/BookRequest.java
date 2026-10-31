package com.library.library_backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;

public class BookRequest {

    @NotBlank(message = "ISBN is required")
    @Size(max = 20, message = "ISBN cannot exceed 20 characters")
    private String isbn;

    @NotBlank(message = "Book title is required")
    @Size(max = 200, message = "Title cannot exceed 200 characters")
    private String title;

    private String description;

    @NotNull(message = "Author ID is required")
    private Integer authorId;

    @NotNull(message = "Publisher ID is required")
    private Integer publisherId;

    @NotNull(message = "Category ID is required")
    private Integer categoryId;

    private String edition;

    @DecimalMin(value = "0.0", message = "Price cannot be negative")
    private BigDecimal price;

    private Integer publicationYear;

    private String coverImage;

      
    // Generate getters and setters for all fields
    // Getters and Setters

public String getIsbn() {
    return isbn;
}

public void setIsbn(String isbn) {
    this.isbn = isbn;
}

public String getTitle() {
    return title;
}

public void setTitle(String title) {
    this.title = title;
}

public String getDescription() {
    return description;
}

public void setDescription(String description) {
    this.description = description;
}

public Integer getAuthorId() {
    return authorId;
}

public void setAuthorId(Integer authorId) {
    this.authorId = authorId;
}

public Integer getPublisherId() {
    return publisherId;
}

public void setPublisherId(Integer publisherId) {
    this.publisherId = publisherId;
}

public Integer getCategoryId() {
    return categoryId;
}

public void setCategoryId(Integer categoryId) {
    this.categoryId = categoryId;
}

public String getEdition() {
    return edition;
}

public void setEdition(String edition) {
    this.edition = edition;
}

public BigDecimal getPrice() {
    return price;
}

public void setPrice(BigDecimal price) {
    this.price = price;
}

public Integer getPublicationYear() {
    return publicationYear;
}

public void setPublicationYear(Integer publicationYear) {
    this.publicationYear = publicationYear;
}

public String getCoverImage() {
    return coverImage;
}

public void setCoverImage(String coverImage) {
    this.coverImage = coverImage;
}
}