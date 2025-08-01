-- Create wrapper functions in pgmq_public schema for PostgREST access
-- These functions wrap the actual pgmq functions to make them accessible via the API

-- Send a message to a queue
CREATE OR REPLACE FUNCTION pgmq_public.send(
    queue_name text,
    message jsonb
) RETURNS bigint AS $$
BEGIN
    RETURN pgmq.send(queue_name, message);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Send multiple messages to a queue
CREATE OR REPLACE FUNCTION pgmq_public.send_batch(
    queue_name text,
    messages jsonb[]
) RETURNS bigint[] AS $$
BEGIN
    RETURN pgmq.send_batch(queue_name, messages);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Read a message from a queue (without removing it)
CREATE OR REPLACE FUNCTION pgmq_public.read(
    queue_name text,
    vt integer DEFAULT 30
) RETURNS TABLE(
    msg_id bigint,
    vt timestamp with time zone,
    message jsonb
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.read(queue_name, vt);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Read a message from a queue with polling
CREATE OR REPLACE FUNCTION pgmq_public.read_with_poll(
    queue_name text,
    vt integer DEFAULT 30,
    poll_interval_ms integer DEFAULT 1000,
    max_polls integer DEFAULT 10
) RETURNS TABLE(
    msg_id bigint,
    vt timestamp with time zone,
    message jsonb
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.read_with_poll(queue_name, vt, poll_interval_ms, max_polls);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pop a message from a queue (removes it)
CREATE OR REPLACE FUNCTION pgmq_public.pop(
    queue_name text
) RETURNS TABLE(
    msg_id bigint,
    vt timestamp with time zone,
    message jsonb
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.pop(queue_name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Archive a message
CREATE OR REPLACE FUNCTION pgmq_public.archive(
    queue_name text,
    msg_id bigint
) RETURNS boolean AS $$
BEGIN
    RETURN pgmq.archive(queue_name, msg_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Delete a message
CREATE OR REPLACE FUNCTION pgmq_public.delete(
    queue_name text,
    msg_id bigint
) RETURNS boolean AS $$
BEGIN
    RETURN pgmq.delete(queue_name, msg_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- List all queues
CREATE OR REPLACE FUNCTION pgmq_public.list_queues()
RETURNS TABLE(
    queue_name text,
    created_at timestamp with time zone
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.list_queues();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get metrics for a specific queue
CREATE OR REPLACE FUNCTION pgmq_public.metrics(
    queue_name text
) RETURNS TABLE(
    queue_name text,
    queue_length bigint,
    newest_msg_age_sec integer,
    oldest_msg_age_sec integer,
    total_messages bigint,
    scrape_time timestamp with time zone
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.metrics(queue_name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get metrics for all queues
CREATE OR REPLACE FUNCTION pgmq_public.metrics_all()
RETURNS TABLE(
    queue_name text,
    queue_length bigint,
    newest_msg_age_sec integer,
    oldest_msg_age_sec integer,
    total_messages bigint,
    scrape_time timestamp with time zone
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM pgmq.metrics_all();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a new queue
CREATE OR REPLACE FUNCTION pgmq_public.create_queue(
    queue_name text
) RETURNS void AS $$
BEGIN
    PERFORM pgmq.create(queue_name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop a queue
CREATE OR REPLACE FUNCTION pgmq_public.drop_queue(
    queue_name text
) RETURNS void AS $$
BEGIN
    PERFORM pgmq.drop_queue(queue_name);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on all functions in pgmq_public schema
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO postgres;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA pgmq_public TO service_role;

-- Grant permissions on future functions in pgmq_public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT EXECUTE ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA pgmq_public GRANT EXECUTE ON FUNCTIONS TO service_role; 