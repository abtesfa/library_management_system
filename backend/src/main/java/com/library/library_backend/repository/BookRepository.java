
package com.library.library_backend.repository;

import com.library.library_backend.entity.book;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookRepository extends JpaRepository<book, Integer> {

    // Search books by title
    List<book> findByTitleContainingIgnoreCase(String keyword);

    // Search books by author name
    List<book> findByAuthor_AuthorNameContainingIgnoreCase(String name);

    // Find a book by ISBN (ISBN is now optional)
    Optional<book> findByIsbn(String isbn);

    // Search books by category name
    @Query("""
        SELECT b FROM book b
        WHERE b.categoryId IN (
            SELECT c.categoryId
            FROM Category c
            WHERE LOWER(c.categoryName)
            LIKE LOWER(CONCAT('%', :name, '%'))
        )
    """)
    List<book> findBooksByCategoryName(@Param("name") String name);

    // Advanced search by title, author, and category
    @Query("""
        SELECT b FROM book b
        WHERE
            (:title IS NULL OR
             LOWER(b.title) LIKE LOWER(CONCAT('%', :title, '%')))
        AND
            (:author IS NULL OR b.author.authorId IN (
                SELECT a.authorId FROM Author a
                WHERE LOWER(a.authorName)
                LIKE LOWER(CONCAT('%', :author, '%'))
            ))
        AND
            (:category IS NULL OR b.categoryId IN (
                SELECT c.categoryId FROM Category c
                WHERE LOWER(c.categoryName)
                LIKE LOWER(CONCAT('%', :category, '%'))
            ))
    """)
    List<book> advancedSearch(
        @Param("title") String title,
        @Param("author") String author,
        @Param("category") String category
    );
}
