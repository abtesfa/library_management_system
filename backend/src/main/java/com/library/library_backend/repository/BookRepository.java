
package com.library.library_backend.repository;

import com.library.library_backend.entity.book;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookRepository extends JpaRepository<book, String> {
    List<book> findByTitleContainingIgnoreCase(String keyword);
    List<book> findByAuthor_AuthorNameContainingIgnoreCase(String name);
   @Query("""
    SELECT b FROM book b
    WHERE b.categoryId IN (
        SELECT c.categoryId
        FROM Category c
        WHERE LOWER(c.categoryName) LIKE LOWER(CONCAT('%', :name, '%'))
    )
""")
List<book> findBooksByCategoryName(@Param("name") String name);
}
