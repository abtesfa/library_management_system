
package com.library.library_backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.FetchType;

import java.math.BigDecimal;

@Entity
@Table(name = "book")
public class book {

    @Id
    @Column(name = "ISBN", length = 20, nullable = false)
    private String isbn;

    @Column(name = "Title", length = 200, nullable = false)
    private String title;

    @Column(name = "Description", columnDefinition = "TEXT")
    private String description;
//entitiy relationship diagram for srping 
// boot before was ust like other column 
//joincloumn points to as aforeign key and manyto one on book side 
@Column(name = "Author_ID", nullable = false, insertable = false, updatable = false)
private Integer authorId;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "Author_ID", nullable = false)
    private Author author;

    @Column(name = "Publisher_ID", nullable = false)
    private Integer publisherId;

    @Column(name = "Category_ID", nullable = false)
    private Integer categoryId;

    @Column(name = "Edition", length = 50)
    private String edition;

    @Column(name = "Price", precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "Publication_Year")
    private Integer publicationYear;

    @Column(name = "CoverImage", length = 255)
    private String coverImage;

    public book() {
    }

    // ISBN
    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    // Title
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    // Description
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    // Author ID
    public Integer getAuthorId() {
        return authorId;
    }
public Author getAuthor() {
    return author;
}

public void setAuthor(Author author) {
    this.author = author;
}
    public void setAuthorId(Integer authorId) {
        this.authorId = authorId;
    }

    // Publisher ID
    public Integer getPublisherId() {
        return publisherId;
    }

    public void setPublisherId(Integer publisherId) {
        this.publisherId = publisherId;
    }

    // Category ID
    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    // Edition
    public String getEdition() {
        return edition;
    }

    public void setEdition(String edition) {
        this.edition = edition;
    }

    // Price
    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    // Publication Year
    public Integer getPublicationYear() {
        return publicationYear;
    }

    public void setPublicationYear(Integer publicationYear) {
        this.publicationYear = publicationYear;
    }

    // Cover Image
    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }
}
