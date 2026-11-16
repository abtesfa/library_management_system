package com.library.library_backend.Controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.library.library_backend.Service.AuthService;
import com.library.library_backend.dto.LoginRequest;
import com.library.library_backend.dto.LoginResponse;
import com.library.library_backend.dto.PasswordChangeRequest;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/change-password")
    public ResponseEntity<Map<String, String>> changePassword(
            @RequestBody PasswordChangeRequest request) {
        authService.changePassword(
                request.getIdentifier(),
                request.getRole(),
                request.getCurrentPassword(),
                request.getNewPassword());

        return ResponseEntity.ok(Map.of(
                "message",
                "Password changed successfully"));
    }
}
