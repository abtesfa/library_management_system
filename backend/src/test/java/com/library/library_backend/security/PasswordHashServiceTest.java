package com.library.library_backend.security;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class PasswordHashServiceTest {

    private final PasswordHashService passwordHashService =
            new PasswordHashService();

    @Test
    void hashesPasswordsWithUniqueSaltsAndVerifiesThem() {
        String firstHash = passwordHashService.hash("password123");
        String secondHash = passwordHashService.hash("password123");

        assertNotEquals(firstHash, secondHash);
        assertTrue(passwordHashService.matches("password123", firstHash));
        assertFalse(passwordHashService.matches("wrong-password", firstHash));
    }

    @Test
    void verifiesHashesGeneratedByTheStudentPasswordScript() {
        String pythonGeneratedHash =
                "pbkdf2_sha256$310000$AAECAwQFBgcICQoLDA0ODw$"
                        + "LVZwDNj6hhmsX38qwZZNyieauFqQ8NLoQxzdE1I025o";

        assertTrue(passwordHashService.matches(
                "password123",
                pythonGeneratedHash));
    }

    @Test
    void acceptsLegacyPlainTextPasswordsForDemoAccounts() {
        assertTrue(passwordHashService.matches("admin123", "admin123"));
        assertTrue(passwordHashService.matches("librarian123", "librarian123"));
        assertTrue(passwordHashService.matches("reader123", "reader123"));
        assertFalse(passwordHashService.matches("wrong-pass", "reader123"));
    }
}
