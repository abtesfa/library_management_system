-- Run once against the existing library database before starting the updated app.
-- Existing staff accounts keep a NULL password hash until a password is set.
ALTER TABLE staff
    ADD COLUMN password_hash VARCHAR(255) NULL,
    ADD COLUMN must_change_password BOOLEAN NOT NULL DEFAULT FALSE;

-- Student.Password stores the encoded PBKDF2 hash, not the raw password.
ALTER TABLE student
    MODIFY COLUMN Password VARCHAR(255) NOT NULL,
    ADD COLUMN must_change_password BOOLEAN NOT NULL DEFAULT FALSE;

-- To bootstrap the first administrator, generate a hash with
-- `python backend/scripts/hash_password.py`, then run:
-- INSERT INTO staff
--     (full_name, email, password_hash, role, position, status, token_version)
-- VALUES
--     ('Library Administrator', 'admin@library.com', '<generated-hash>',
--      'ADMIN', NULL, 'ACTIVE', 0);
