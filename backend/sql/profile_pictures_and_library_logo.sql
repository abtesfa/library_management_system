-- Run once against the existing MySQL database before starting the updated backend.
ALTER TABLE staff ADD COLUMN profile_picture LONGBLOB NULL;
ALTER TABLE student ADD COLUMN profile_picture LONGBLOB NULL;
ALTER TABLE library_settings ADD COLUMN library_logo LONGBLOB NULL;
