Database migration V2

For an existing database, run V2__rename_daily_limit_to_per_student_limit.sql once
before starting the updated backend. It renames the old setting column without
losing its configured value. Do not run it more than once.

The project currently uses Hibernate ddl-auto=update rather than Flyway, so this
SQL is supplied as a manual migration and is not automatically executed.
