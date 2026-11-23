# Update notes – profile pictures and library logo

Before starting the updated backend, run `sql/profile_pictures_and_library_logo.sql` once against the existing MySQL database. It adds nullable `LONGBLOB` columns to `staff`, `student`, and `library_settings`. Existing rows remain valid and will show initials / the book icon until images are uploaded.

Image uploads are limited to 5 MB and accept JPEG, PNG, and WEBP. Endpoints:
- `PUT /api/profile-pictures/{role}/{id}` multipart field `file` (`STUDENT`, `ADMIN`, or `LIBRARIAN`)
- `GET /api/profile-pictures/{role}/{id}`
- `PUT /api/settings/logo` multipart field `file`
- `GET /api/settings/logo`

The settings JSON includes the logo as Base64 in `libraryLogo` for the existing Flutter settings loader.


## School contact settings

The `library_settings` entity now includes nullable `school_email` and `school_location` columns. With the existing `spring.jpa.hibernate.ddl-auto=update` configuration, Hibernate should add these columns when the backend starts. If schema auto-update is disabled, add them manually:

```sql
ALTER TABLE library_settings
  ADD COLUMN school_email VARCHAR(255) NULL,
  ADD COLUMN school_location VARCHAR(500) NULL;
```

The existing settings GET/PUT endpoint serializes `LibrarySettings` directly, so the new `schoolEmail` and `schoolLocation` JSON properties are returned and accepted automatically.
