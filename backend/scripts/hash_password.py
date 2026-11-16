import base64
import getpass
import hashlib
import secrets
import sys

ITERATIONS = 310_000


def encode_base64(value: bytes) -> str:
    return base64.b64encode(value).decode("ascii").rstrip("=")


def main() -> None:
    password = getpass.getpass("New password (8+ characters): ")
    confirmation = getpass.getpass("Confirm password: ")

    if len(password) < 8:
        sys.exit("Password must be at least 8 characters.")
    if password != confirmation:
        sys.exit("Passwords do not match.")

    salt = secrets.token_bytes(16)
    derived_key = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        ITERATIONS,
        dklen=32,
    )

    print(
        "Copy this hash into the account's password_hash or Password column:\n"
        f"pbkdf2_sha256${ITERATIONS}$"
        f"{encode_base64(salt)}${encode_base64(derived_key)}"
    )


if __name__ == "__main__":
    main()
