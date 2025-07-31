CREATE TYPE task_status_enum AS ENUM (
    'enqueued',
    'processing',
    'succeeded',
    'failed',
    'canceled'
    );

CREATE TYPE listing_status_enum AS ENUM (
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

CREATE TYPE roles_enum as ENUM (
    'admin',
    'partner',
    'customer'
    );

CREATE TABLE roles
(
    id         UUID PRIMARY KEY           DEFAULT gen_random_uuid(),
    name       roles_enum UNIQUE NOT NULL DEFAULT 'customer',
    created_at TIMESTAMPTZ                DEFAULT now(),
    updated_at TIMESTAMPTZ                DEFAULT now()
);

CREATE TABLE users
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email      VARCHAR(255) UNIQUE NOT NULL,
    role_id    UUID                NOT NULL REFERENCES roles (id),
    username   VARCHAR(255),
    created_at TIMESTAMPTZ      DEFAULT now(),
    updated_at TIMESTAMPTZ      DEFAULT now()
);

CREATE TABLE addresses
(
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude          DECIMAL(9, 6),
    longitude         DECIMAL(9, 6),
    city              VARCHAR(255),
    district          VARCHAR(255),
    street_number     VARCHAR(255),
    street            VARCHAR(255),
    region            VARCHAR(255),
    subregion         VARCHAR(255),
    country           VARCHAR(255),
    postal_code       VARCHAR(255),
    name_address      VARCHAR(255),
    iso_country_code  VARCHAR(10),
    timezone          VARCHAR(64),
    formatted_address TEXT,
    created_at        TIMESTAMPTZ      DEFAULT now(),
    updated_at        TIMESTAMPTZ      DEFAULT now()
);

CREATE TABLE user_addresses
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID REFERENCES users (id) ON DELETE CASCADE,
    address_id UUID REFERENCES addresses (id) ON DELETE CASCADE,
    is_primary BOOLEAN          DEFAULT FALSE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (user_id, address_id)
);

CREATE TABLE phones
(
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number       VARCHAR(32) NOT NULL,
    is_primary   BOOLEAN          DEFAULT FALSE,
    is_verified  BOOLEAN          DEFAULT FALSE,
    country_code VARCHAR(8)  NOT NULL,
    created_at   TIMESTAMPTZ      DEFAULT now(),
    updated_at   TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (number, country_code)
);

CREATE TABLE user_phones
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID REFERENCES users (id) ON DELETE CASCADE,
    phone_id   UUID REFERENCES phones (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (user_id, phone_id)
);

CREATE TABLE images
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    url        TEXT UNIQUE NOT NULL,
    is_primary BOOLEAN          DEFAULT FALSE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    updated_at TIMESTAMPTZ      DEFAULT now()
);

CREATE TABLE user_images
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID REFERENCES users (id) ON DELETE CASCADE,
    image_id   UUID REFERENCES images (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (user_id, image_id)
);

CREATE TABLE tasks
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_uid    INTEGER UNIQUE NOT NULL,
    index_uid   VARCHAR(100),
    task_type   VARCHAR(50)    NOT NULL,
    task_status task_status_enum DEFAULT 'enqueued',
    enqueued_at TIMESTAMPTZ,
    started_at  TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ      DEFAULT now(),
    updated_at  TIMESTAMPTZ      DEFAULT now()
);

CREATE TABLE statuses
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ      DEFAULT now(),
    updated_at  TIMESTAMPTZ      DEFAULT now()
);

CREATE TABLE listings
(
    id          UUID PRIMARY KEY    DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    owner_id    UUID REFERENCES users (id),
    address_id  UUID REFERENCES addresses (id),
    description TEXT         NOT NULL,
    version     INTEGER             DEFAULT 1,
    status      listing_status_enum DEFAULT 'draft',
    task_id     UUID REFERENCES tasks (id),
    created_at  TIMESTAMPTZ         DEFAULT now(),
    updated_at  TIMESTAMPTZ         DEFAULT now(),
    UNIQUE (name, owner_id)
);


CREATE TABLE listing_images
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES listings (id) ON DELETE CASCADE,
    image_id   UUID REFERENCES images (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (listing_id, image_id)
);

CREATE TABLE listing_phones
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES listings (id) ON DELETE CASCADE,
    phone_id   UUID REFERENCES phones (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (listing_id, phone_id)
);

CREATE TABLE listing_logs
(
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id    UUID REFERENCES listings (id) ON DELETE CASCADE,
    status        listing_status_enum,
    task_id       UUID REFERENCES tasks (id),
    changed_by_id UUID REFERENCES users (id),
    version       INTEGER          DEFAULT 1,
    comment       TEXT,
    created_at    TIMESTAMPTZ      DEFAULT now(),
    updated_at    TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (listing_id, version)
);

CREATE TABLE interactions
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(50) NOT NULL,
    listing_id UUID REFERENCES listings (id) ON DELETE CASCADE,
    user_id    UUID REFERENCES users (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ      DEFAULT now(),
    updated_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (name, listing_id, user_id)
);

CREATE TABLE opening_hours
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id  UUID REFERENCES listings (id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL,
    open_time   TIME    NOT NULL,
    close_time  TIME    NOT NULL,
    is_closed   BOOLEAN          DEFAULT FALSE,
    UNIQUE (listing_id, day_of_week)
);

CREATE TABLE social_networks
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES listings (id) ON DELETE CASCADE,
    network    VARCHAR(50) NOT NULL,
    url        TEXT        NOT NULL,
    handle     VARCHAR(255),
    created_at TIMESTAMPTZ      DEFAULT now(),
    UNIQUE (listing_id, network)
);

/*
 * Function: is_admin()
 * Description: Checks if the currently authenticated user has admin role
 * Returns: boolean
 *   - true if user is an admin
 *   - false otherwise
 * Notes:
 *   - Uses auth.uid() to get current user ID
 *   - Joins profiles and roles tables to check role
 *   - Marked as STABLE since output depends only on input
 */
CREATE OR REPLACE FUNCTION is_admin()
    RETURNS BOOLEAN
    SECURITY DEFINER
    STABLE
AS
$$
SELECT EXISTS (SELECT 1
               FROM users p
                        JOIN roles r ON p.role_id = r.id
               WHERE p.id = auth.uid()
                 AND r.name = 'admin');
$$ LANGUAGE SQL;

REVOKE ALL ON FUNCTION is_admin() FROM public;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;

-- DESCRIPTION: This function is helpful to seed the database with users only, not to be used in production
CREATE
    OR REPLACE FUNCTION create_user(
    user_id uuid,
    email text,
    password text
) RETURNS void AS
$$
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
$$
    LANGUAGE plpgsql;

-- roles example how to use is_admin()
-- ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Admins only" ON roles FOR ALL USING (is_admin()) WITH CHECK (is_admin());
