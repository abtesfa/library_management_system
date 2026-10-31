package com.library.library_backend.Controller;

import com.library.library_backend.dto.AuthorBooksResponse;
import com.library.library_backend.Service.AuthorService;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/authors")
@CrossOrigin(origins = "*")
public class AuthorController {

    private final AuthorService authorService;

    public AuthorController(AuthorService authorService) {
        this.authorService = authorService;
    }

    @GetMapping("/{id}/books")
    public AuthorBooksResponse getAuthorBooks(
            @PathVariable Integer id) {

        return authorService.getAuthorBooks(id);
    }
}