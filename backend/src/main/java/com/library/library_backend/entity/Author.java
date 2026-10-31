
package com.library.library_backend.entity;
import java.util.List;
import java.util.ArrayList;
import jakarta.persistence.*;
import com.library.library_backend.entity.book;
import jakarta.persistence.OneToMany;
@Entity
@Table(name = "author")
public class Author {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Author_ID")
    private Integer authorId;
    @OneToMany(mappedBy = "author")
     private List<book> books = new ArrayList<>();

    @Column(name = "Author_Name", nullable = false, length = 150)
    private String authorName;

    public Author() {
    }

    public Integer getAuthorId() {
        return authorId;
    }

    public void setAuthorId(Integer authorId) {
        this.authorId = authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }
    public List<book> getBooks() {
    return books;
}

public void setBooks(List<book> books) {
    this.books = books;
}
}

