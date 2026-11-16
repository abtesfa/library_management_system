package com.library.library_backend.dto;

import java.util.Set;

public record LoginResponse(
        String accountId,
        String fullName,
        String email,
        String role,
        String title,
        boolean requiresPasswordChange,
        Set<String> permissions) {
}
