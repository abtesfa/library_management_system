-- Reservation allocation, structured announcements, and department recommendations.
-- Apply after V2. Existing reservation records are retained.
ALTER TABLE reservations
    ADD COLUMN Copy_ID INT NULL;

ALTER TABLE borrowing
    ADD COLUMN Original_Due_Date DATE NULL;

UPDATE borrowing SET Original_Due_Date = Due_Date WHERE Original_Due_Date IS NULL;

ALTER TABLE notifications
    ADD COLUMN announcement_priority VARCHAR(20) NULL,
    ADD COLUMN audience_positions TEXT NULL,
    ADD COLUMN valid_from DATE NULL,
    ADD COLUMN valid_until DATE NULL,
    ADD COLUMN is_archived BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS book_department (
    Book_ID INT NOT NULL,
    Department VARCHAR(100) NOT NULL,
    PRIMARY KEY (Book_ID, Department),
    CONSTRAINT fk_book_department_book FOREIGN KEY (Book_ID)
        REFERENCES book(Book_ID) ON DELETE CASCADE,
    INDEX idx_book_department_department (Department)
);

-- Existing reservation rows that were previously given a hold deadline while
-- still WAITING must return to the queue; the hold begins only after allocation.
UPDATE reservations
SET Hold_Until = NULL
WHERE Status = 'WAITING';

-- Keep legacy rows valid; no existing notification is deleted.
