package com.library.library_backend.security;

import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Set;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import org.springframework.stereotype.Service;

@Service
public class PasswordHashService {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final String PREFIX = "pbkdf2_sha256";
    private static final int ITERATIONS = 310_000;
    private static final int SALT_BYTES = 16;
    private static final int KEY_BITS = 256;
    private static final int MAX_ACCEPTED_ITERATIONS = 1_000_000;
    private static final Set<String> LEGACY_DEMO_PASSWORDS =
            Set.of("admin123", "librarian123", "reader123");

    private final SecureRandom secureRandom = new SecureRandom();

    public String hash(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password is required.");
        }

        byte[] salt = new byte[SALT_BYTES];
        secureRandom.nextBytes(salt);
        byte[] derivedKey = deriveKey(password, salt, ITERATIONS);

        return PREFIX + "$" + ITERATIONS + "$"
                + Base64.getEncoder().withoutPadding().encodeToString(salt)
                + "$"
                + Base64.getEncoder().withoutPadding().encodeToString(derivedKey);
    }

    public boolean matches(String password, String encodedPassword) {
        if (password == null || encodedPassword == null) return false;

        if (LEGACY_DEMO_PASSWORDS.contains(password)
                && LEGACY_DEMO_PASSWORDS.contains(encodedPassword)
                && password.equals(encodedPassword)) {
            return true;
        }

        if (!encodedPassword.startsWith(PREFIX + "$")) {
            return false;
        }

        String[] parts = encodedPassword.split("\\$", -1);
        if (parts.length != 4 || !PREFIX.equals(parts[0])) return false;

        final int iterations;
        final byte[] salt;
        final byte[] expectedKey;
        try {
            iterations = Integer.parseInt(parts[1]);
            salt = Base64.getDecoder().decode(parts[2]);
            expectedKey = Base64.getDecoder().decode(parts[3]);
        } catch (IllegalArgumentException exception) {
            return false;
        }

        if (iterations < 1 || iterations > MAX_ACCEPTED_ITERATIONS
                || salt.length < 16 || expectedKey.length != KEY_BITS / 8) {
            return false;
        }

        return MessageDigest.isEqual(
                expectedKey,
                deriveKey(password, salt, iterations));
    }

    private byte[] deriveKey(String password, byte[] salt, int iterations) {
        PBEKeySpec keySpec = new PBEKeySpec(
                password.toCharArray(),
                salt,
                iterations,
                KEY_BITS);
        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            return factory.generateSecret(keySpec).getEncoded();
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException(
                    "Password hashing is unavailable.", exception);
        } finally {
            keySpec.clearPassword();
        }
    }
}
