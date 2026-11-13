package com.library.library_backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.library.library_backend.entity.book;

public interface BookRepository extends JpaRepository<book, Integer> {

    List<book> findByTitleContainingIgnoreCase(String keyword);

    Optional<book> findByIsbn(String isbn);
}
