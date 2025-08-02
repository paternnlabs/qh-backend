


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";


CREATE SCHEMA IF NOT EXISTS "pgmq";


CREATE SCHEMA IF NOT EXISTS "pgmq_public";


ALTER SCHEMA "pgmq_public" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgmq" WITH SCHEMA "pgmq";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."listing_status_enum" AS ENUM (
    'draft',
    'ready_for_review',
    'under_review',
    'changes_requested',
    'approved',
    'published',
    'rejected',
    'expired',
    'archived',
    'canceled'
);


ALTER TYPE "public"."listing_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."roles_enum" AS ENUM (
    'admin',
    'partner',
    'customer'
);


ALTER TYPE "public"."roles_enum" OWNER TO "postgres";


CREATE TYPE "public"."task_status_enum" AS ENUM (
    'enqueued',
    'processing',
    'succeeded',
    'failed',
    'canceled'
);


ALTER TYPE "public"."task_status_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) RETURNS boolean
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return pgmq.archive( queue_name := queue_name, msg_id := message_id ); end; $$;


ALTER FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) IS 'Archives a message by moving it from the queue to a permanent archive.';



CREATE OR REPLACE FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) RETURNS boolean
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return pgmq.delete( queue_name := queue_name, msg_id := message_id ); end; $$;


ALTER FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) IS 'Permanently deletes a message from the specified queue.';



CREATE OR REPLACE FUNCTION "pgmq_public"."pop"("queue_name" "text") RETURNS SETOF "pgmq"."message_record"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return query select * from pgmq.pop( queue_name := queue_name ); end; $$;


ALTER FUNCTION "pgmq_public"."pop"("queue_name" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."pop"("queue_name" "text") IS 'Retrieves and locks the next message from the specified queue.';



CREATE OR REPLACE FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) RETURNS SETOF "pgmq"."message_record"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return query select * from pgmq.read( queue_name := queue_name, vt := sleep_seconds, qty := n ); end; $$;


ALTER FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) IS 'Reads up to "n" messages from the specified queue with an optional "sleep_seconds" (visibility timeout).';



CREATE OR REPLACE FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer DEFAULT 0) RETURNS SETOF bigint
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return query select * from pgmq.send( queue_name := queue_name, msg := message, delay := sleep_seconds ); end; $$;


ALTER FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer) IS 'Sends a message to the specified queue, optionally delaying its availability by a number of seconds.';



CREATE OR REPLACE FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer DEFAULT 0) RETURNS SETOF bigint
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$ begin return query select * from pgmq.send_batch( queue_name := queue_name, msgs := messages, delay := sleep_seconds ); end; $$;


ALTER FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer) IS 'Sends a batch of messages to the specified queue, optionally delaying their availability by a number of seconds.';



CREATE OR REPLACE FUNCTION "public"."create_user"("user_id" "uuid", "email" "text", "password" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
    encrypted_pw
        text;
BEGIN
    encrypted_pw
        := extensions.crypt(password, extensions.gen_salt('bf'));

    INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at,
     raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change,
     email_change_token_new, recovery_token)
    VALUES ('00000000-0000-0000-0000-000000000000', user_id, 'authenticated', 'authenticated', create_user.email,
            encrypted_pw,
            '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00',
            '{
              "provider": "email",
              "providers": [
                "email"
              ]
            }', '{}', '2023-05-03 19:41:43.580424+00',
            '2023-05-03 19:41:43.585948+00', '', '', '', '');
    INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at,
                                 updated_at)
    VALUES (gen_random_uuid(), user_id, user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb,
            'email',
            '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
END;
$$;


ALTER FUNCTION "public"."create_user"("user_id" "uuid", "email" "text", "password" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (SELECT 1
               FROM users p
                        JOIN roles r ON p.role_id = r.id
               WHERE p.id = auth.uid()
                 AND r.name = 'admin');
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."addresses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "city" character varying(255),
    "district" character varying(255),
    "street_number" character varying(255),
    "street" character varying(255),
    "region" character varying(255),
    "subregion" character varying(255),
    "country" character varying(255),
    "postal_code" character varying(255),
    "name_address" character varying(255),
    "iso_country_code" character varying(10),
    "timezone" character varying(64),
    "formatted_address" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."addresses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."images" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "url" "text" NOT NULL,
    "is_primary" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."images" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."interactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(50) NOT NULL,
    "listing_id" "uuid",
    "user_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."interactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."listing_images" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "uuid",
    "image_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."listing_images" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."listing_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "uuid",
    "status" "public"."listing_status_enum",
    "task_id" "uuid",
    "changed_by_id" "uuid",
    "version" integer DEFAULT 1,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."listing_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."listing_phones" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "uuid",
    "phone_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."listing_phones" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."listings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "owner_id" "uuid",
    "address_id" "uuid",
    "description" "text" NOT NULL,
    "version" integer DEFAULT 1,
    "status" "public"."listing_status_enum" DEFAULT 'draft'::"public"."listing_status_enum",
    "task_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."listings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."opening_hours" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "uuid",
    "day_of_week" integer NOT NULL,
    "open_time" time without time zone NOT NULL,
    "close_time" time without time zone NOT NULL,
    "is_closed" boolean DEFAULT false
);


ALTER TABLE "public"."opening_hours" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."phones" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "number" character varying(32) NOT NULL,
    "is_primary" boolean DEFAULT false,
    "is_verified" boolean DEFAULT false,
    "country_code" character varying(8) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."phones" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "public"."roles_enum" DEFAULT 'customer'::"public"."roles_enum" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."social_networks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "listing_id" "uuid",
    "network" character varying(50) NOT NULL,
    "url" "text" NOT NULL,
    "handle" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."social_networks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."statuses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(20) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."statuses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_uid" integer NOT NULL,
    "index_uid" character varying(100),
    "task_type" character varying(50) NOT NULL,
    "task_status" "public"."task_status_enum" DEFAULT 'enqueued'::"public"."task_status_enum",
    "enqueued_at" timestamp with time zone,
    "started_at" timestamp with time zone,
    "finished_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."tasks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_addresses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "address_id" "uuid",
    "is_primary" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_addresses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_images" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "image_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_images" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_phones" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "phone_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_phones" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" character varying(255) NOT NULL,
    "role_id" "uuid" NOT NULL,
    "username" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."addresses"
    ADD CONSTRAINT "addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."images"
    ADD CONSTRAINT "images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."images"
    ADD CONSTRAINT "images_url_key" UNIQUE ("url");



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_name_listing_id_user_id_key" UNIQUE ("name", "listing_id", "user_id");



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."listing_images"
    ADD CONSTRAINT "listing_images_listing_id_image_id_key" UNIQUE ("listing_id", "image_id");



ALTER TABLE ONLY "public"."listing_images"
    ADD CONSTRAINT "listing_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."listing_logs"
    ADD CONSTRAINT "listing_logs_listing_id_version_key" UNIQUE ("listing_id", "version");



ALTER TABLE ONLY "public"."listing_logs"
    ADD CONSTRAINT "listing_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."listing_phones"
    ADD CONSTRAINT "listing_phones_listing_id_phone_id_key" UNIQUE ("listing_id", "phone_id");



ALTER TABLE ONLY "public"."listing_phones"
    ADD CONSTRAINT "listing_phones_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_name_owner_id_key" UNIQUE ("name", "owner_id");



ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."opening_hours"
    ADD CONSTRAINT "opening_hours_listing_id_day_of_week_key" UNIQUE ("listing_id", "day_of_week");



ALTER TABLE ONLY "public"."opening_hours"
    ADD CONSTRAINT "opening_hours_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."phones"
    ADD CONSTRAINT "phones_number_country_code_key" UNIQUE ("number", "country_code");



ALTER TABLE ONLY "public"."phones"
    ADD CONSTRAINT "phones_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."social_networks"
    ADD CONSTRAINT "social_networks_listing_id_network_key" UNIQUE ("listing_id", "network");



ALTER TABLE ONLY "public"."social_networks"
    ADD CONSTRAINT "social_networks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_task_uid_key" UNIQUE ("task_uid");



ALTER TABLE ONLY "public"."user_addresses"
    ADD CONSTRAINT "user_addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_addresses"
    ADD CONSTRAINT "user_addresses_user_id_address_id_key" UNIQUE ("user_id", "address_id");



ALTER TABLE ONLY "public"."user_images"
    ADD CONSTRAINT "user_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_images"
    ADD CONSTRAINT "user_images_user_id_image_id_key" UNIQUE ("user_id", "image_id");



ALTER TABLE ONLY "public"."user_phones"
    ADD CONSTRAINT "user_phones_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_phones"
    ADD CONSTRAINT "user_phones_user_id_phone_id_key" UNIQUE ("user_id", "phone_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listing_images"
    ADD CONSTRAINT "listing_images_image_id_fkey" FOREIGN KEY ("image_id") REFERENCES "public"."images"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listing_images"
    ADD CONSTRAINT "listing_images_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listing_logs"
    ADD CONSTRAINT "listing_logs_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."listing_logs"
    ADD CONSTRAINT "listing_logs_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listing_logs"
    ADD CONSTRAINT "listing_logs_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id");



ALTER TABLE ONLY "public"."listing_phones"
    ADD CONSTRAINT "listing_phones_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listing_phones"
    ADD CONSTRAINT "listing_phones_phone_id_fkey" FOREIGN KEY ("phone_id") REFERENCES "public"."phones"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "public"."addresses"("id");



ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id");



ALTER TABLE ONLY "public"."opening_hours"
    ADD CONSTRAINT "opening_hours_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."social_networks"
    ADD CONSTRAINT "social_networks_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_addresses"
    ADD CONSTRAINT "user_addresses_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "public"."addresses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_addresses"
    ADD CONSTRAINT "user_addresses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_images"
    ADD CONSTRAINT "user_images_image_id_fkey" FOREIGN KEY ("image_id") REFERENCES "public"."images"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_images"
    ADD CONSTRAINT "user_images_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_phones"
    ADD CONSTRAINT "user_phones_phone_id_fkey" FOREIGN KEY ("phone_id") REFERENCES "public"."phones"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_phones"
    ADD CONSTRAINT "user_phones_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id");





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "pgmq_public" TO "anon";
GRANT USAGE ON SCHEMA "pgmq_public" TO "authenticated";
GRANT USAGE ON SCHEMA "pgmq_public" TO "service_role";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
































































































































































































GRANT ALL ON FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."archive"("queue_name" "text", "message_id" bigint) TO "authenticated";



GRANT ALL ON FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."delete"("queue_name" "text", "message_id" bigint) TO "authenticated";



GRANT ALL ON FUNCTION "pgmq_public"."pop"("queue_name" "text") TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."pop"("queue_name" "text") TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."pop"("queue_name" "text") TO "authenticated";



GRANT ALL ON FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."read"("queue_name" "text", "sleep_seconds" integer, "n" integer) TO "authenticated";



GRANT ALL ON FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer) TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer) TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."send"("queue_name" "text", "message" "jsonb", "sleep_seconds" integer) TO "authenticated";



GRANT ALL ON FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer) TO "service_role";
GRANT ALL ON FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer) TO "anon";
GRANT ALL ON FUNCTION "pgmq_public"."send_batch"("queue_name" "text", "messages" "jsonb"[], "sleep_seconds" integer) TO "authenticated";



GRANT ALL ON FUNCTION "public"."create_user"("user_id" "uuid", "email" "text", "password" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_user"("user_id" "uuid", "email" "text", "password" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user"("user_id" "uuid", "email" "text", "password" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



























GRANT ALL ON TABLE "public"."addresses" TO "anon";
GRANT ALL ON TABLE "public"."addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."addresses" TO "service_role";



GRANT ALL ON TABLE "public"."images" TO "anon";
GRANT ALL ON TABLE "public"."images" TO "authenticated";
GRANT ALL ON TABLE "public"."images" TO "service_role";



GRANT ALL ON TABLE "public"."interactions" TO "anon";
GRANT ALL ON TABLE "public"."interactions" TO "authenticated";
GRANT ALL ON TABLE "public"."interactions" TO "service_role";



GRANT ALL ON TABLE "public"."listing_images" TO "anon";
GRANT ALL ON TABLE "public"."listing_images" TO "authenticated";
GRANT ALL ON TABLE "public"."listing_images" TO "service_role";



GRANT ALL ON TABLE "public"."listing_logs" TO "anon";
GRANT ALL ON TABLE "public"."listing_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."listing_logs" TO "service_role";



GRANT ALL ON TABLE "public"."listing_phones" TO "anon";
GRANT ALL ON TABLE "public"."listing_phones" TO "authenticated";
GRANT ALL ON TABLE "public"."listing_phones" TO "service_role";



GRANT ALL ON TABLE "public"."listings" TO "anon";
GRANT ALL ON TABLE "public"."listings" TO "authenticated";
GRANT ALL ON TABLE "public"."listings" TO "service_role";



GRANT ALL ON TABLE "public"."opening_hours" TO "anon";
GRANT ALL ON TABLE "public"."opening_hours" TO "authenticated";
GRANT ALL ON TABLE "public"."opening_hours" TO "service_role";



GRANT ALL ON TABLE "public"."phones" TO "anon";
GRANT ALL ON TABLE "public"."phones" TO "authenticated";
GRANT ALL ON TABLE "public"."phones" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."social_networks" TO "anon";
GRANT ALL ON TABLE "public"."social_networks" TO "authenticated";
GRANT ALL ON TABLE "public"."social_networks" TO "service_role";



GRANT ALL ON TABLE "public"."statuses" TO "anon";
GRANT ALL ON TABLE "public"."statuses" TO "authenticated";
GRANT ALL ON TABLE "public"."statuses" TO "service_role";



GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";



GRANT ALL ON TABLE "public"."user_addresses" TO "anon";
GRANT ALL ON TABLE "public"."user_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."user_addresses" TO "service_role";



GRANT ALL ON TABLE "public"."user_images" TO "anon";
GRANT ALL ON TABLE "public"."user_images" TO "authenticated";
GRANT ALL ON TABLE "public"."user_images" TO "service_role";



GRANT ALL ON TABLE "public"."user_phones" TO "anon";
GRANT ALL ON TABLE "public"."user_phones" TO "authenticated";
GRANT ALL ON TABLE "public"."user_phones" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
