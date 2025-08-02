
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
