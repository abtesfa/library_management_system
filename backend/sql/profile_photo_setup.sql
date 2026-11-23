-- Run once against the library database if Hibernate has not already added
-- these nullable columns. Profile photo data is stored as binary image bytes.
ALTER TABLE student
    ADD COLUMN profile_photo LONGBLOB NULL;

ALTER TABLE staff
    ADD COLUMN profile_photo LONGBLOB NULL;
