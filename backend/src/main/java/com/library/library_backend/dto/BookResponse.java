
package com.library.library_backend.dto;

public class BookResponse {

    /** Book_ID as text (not the ISBN). */
    private String id;
    private String title;
    private String author;
    private String isbn;
    private String category;
    private int totalCopies;
    /** Copies on the shelf that are not held by an active reservation. */
    private int availableCopies;

    /** Shelf copies currently held for students who reserved them. */
    private int reservedCopies;
    private String status;
    private String location;
    private String coverTheme;
    private String publisher;
    private String edition;
    private Integer publicationYear;
    private String description;
    private String coverImage;

    public BookResponse(
            String id,
            String title,
            String author,
            String isbn,
            String category,
            int totalCopies,
            int availableCopies,
            int reservedCopies,
            String status,
            String location,
            String coverTheme,
            String publisher,
            String edition,
            Integer publicationYear,
            String description,
            String coverImage) {

        this.id = id;
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.category = category;
        this.totalCopies = totalCopies;
        this.availableCopies = availableCopies;
        this.reservedCopies = reservedCopies;
        this.status = status;
        this.location = location;
        this.coverTheme = coverTheme;
        this.publisher = publisher;
        this.edition = edition;
        this.publicationYear = publicationYear;
        this.description = description;
        this.coverImage = coverImage;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }

    public String getIsbn() {
        return isbn;
    }

    public String getCategory() {
        return category;
    }

    public int getTotalCopies() {
        return totalCopies;
    }

    public int getAvailableCopies() {
        return availableCopies;
    }

    public int getReservedCopies() {
        return reservedCopies;
    }

    public String getStatus() {
        return status;
    }

    public String getLocation() {
        return location;
    }

    public String getCoverTheme() {
        return coverTheme;
    }

    public String getPublisher() {
        return publisher;
    }

    public String getEdition() {
        return edition;
    }

    public Integer getPublicationYear() {
        return publicationYear;
    }

    public String getDescription() {
        return description;
    }

    public String getCoverImage() {
        return coverImage;
    }
}
