
package com.library.library_backend.repository;

import com.library.library_backend.entity.book;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<book, String> {
}
