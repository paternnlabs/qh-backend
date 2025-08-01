-- Enable pg_cron extension for scheduling recurring jobs
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Enable pgmq extension for message queue functionality
CREATE EXTENSION IF NOT EXISTS pgmq;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT USAGE ON SCHEMA pgmq TO postgres;

-- Create pgmq_public schema if it doesn't exist (for PostgREST access)
CREATE SCHEMA IF NOT EXISTS pgmq_public;

-- Grant permissions for pgmq_public schema (for PostgREST access)
GRANT USAGE ON SCHEMA pgmq_public TO postgres;
GRANT USAGE ON SCHEMA pgmq_public TO anon;
GRANT USAGE ON SCHEMA pgmq_public TO authenticated;
GRANT USAGE ON SCHEMA pgmq_public TO service_role;

-- Grant execute permissions on pgmq functions (if they exist)
DO $$
BEGIN
    -- Grant execute permissions on existing functions in pgmq_public schema
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'pgmq_public') THEN
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO postgres;
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO anon;
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO authenticated;
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO service_role;
    END IF;
END $$;

-- Grant permissions on pgmq tables (if they exist)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'pgmq_public') THEN
        GRANT ALL ON ALL TABLES IN SCHEMA pgmq_public TO postgres;
        GRANT ALL ON ALL TABLES IN SCHEMA pgmq_public TO anon;
        GRANT ALL ON ALL TABLES IN SCHEMA pgmq_public TO authenticated;
        GRANT ALL ON ALL TABLES IN SCHEMA pgmq_public TO service_role;
    END IF;
END $$;

-- Grant permissions on future tables in pgmq_public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT ALL ON TABLES TO service_role;