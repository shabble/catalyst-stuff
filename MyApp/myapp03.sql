--
-- Add 'created' and 'updated' columns to 'book' table.
--
ALTER TABLE book ADD created TIMESTAMP;
ALTER TABLE book ADD updated TIMESTAMP;
UPDATE book SET created = DATETIME('NOW'), updated = DATETIME('NOW');
