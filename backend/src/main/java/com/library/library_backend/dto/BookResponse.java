
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
            String coverTheme) {

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
}
