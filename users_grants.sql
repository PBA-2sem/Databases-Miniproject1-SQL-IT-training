-- Create role with read access
CREATE ROLE readaccess;
-- Grant access to existing tables
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
-- Grant access to future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readaccess;

-- Create users
CREATE USER superuser WITH PASSWORD 'superuser';
CREATE USER instructor WITH PASSWORD 'instructor';
CREATE USER trainee WITH PASSWORD 'trainee';

-- Grant privileges to users
ALTER USER superuser WITH SUPERUSER;
GRANT readaccess TO instructor;
GRANT readaccess TO trainee;
