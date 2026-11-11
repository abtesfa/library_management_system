
package com.library.library_backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class BookRequest {

    // Required book title
    @NotBlank(message = "Book title is required")
    @Size(max = 200, message = "Title cannot exceed 200 characters")
    private String title;

    // Required author name
    @NotBlank(message = "Author name is required")
    @Size(max = 150, message = "Author name cannot exceed 150 characters")
    private String authorName;

    // Required category selected from dropdown
    @NotNull(message = "Please select a category")
    private Integer categoryId;

    // Required number of physical copies
    @NotNull(message = "Number of copies is required")
    @Min(value = 1, message = "At least one copy is required")
    private Integer numberOfCopies;

    // Optional shelf location
    @Size(max = 100, message = "Location cannot exceed 100 characters")
    private String location;

    public BookRequest() {
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getNumberOfCopies() {
        return numberOfCopies;
    }

    public void setNumberOfCopies(Integer numberOfCopies) {
        this.numberOfCopies = numberOfCopies;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}
