create type "public"."listing_status_enum" as enum ('draft', 'ready_for_review', 'under_review', 'changes_requested', 'approved', 'published', 'rejected', 'expired', 'archived', 'canceled');

create type "public"."roles_enum" as enum ('admin', 'partner', 'customer');

create type "public"."task_status_enum" as enum ('enqueued', 'processing', 'succeeded', 'failed', 'canceled');

create table "public"."addresses" (
    "id" uuid not null default gen_random_uuid(),
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
    "formatted_address" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."images" (
    "id" uuid not null default gen_random_uuid(),
    "url" text not null,
    "is_primary" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."interactions" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying(50) not null,
    "listing_id" uuid,
    "user_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."listing_images" (
    "id" uuid not null default gen_random_uuid(),
    "listing_id" uuid,
    "image_id" uuid,
    "created_at" timestamp with time zone default now()
);


create table "public"."listing_logs" (
    "id" uuid not null default gen_random_uuid(),
    "listing_id" uuid,
    "status" listing_status_enum,
    "task_id" uuid,
    "changed_by_id" uuid,
    "version" integer default 1,
    "comment" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."listing_phones" (
    "id" uuid not null default gen_random_uuid(),
    "listing_id" uuid,
    "phone_id" uuid,
    "created_at" timestamp with time zone default now()
);


create table "public"."listings" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying(255) not null,
    "owner_id" uuid,
    "address_id" uuid,
    "description" text not null,
    "version" integer default 1,
    "status" listing_status_enum default 'draft'::listing_status_enum,
    "task_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."opening_hours" (
    "id" uuid not null default gen_random_uuid(),
    "listing_id" uuid,
    "day_of_week" integer not null,
    "open_time" time without time zone not null,
    "close_time" time without time zone not null,
    "is_closed" boolean default false
);


create table "public"."phones" (
    "id" uuid not null default gen_random_uuid(),
    "number" character varying(32) not null,
    "is_primary" boolean default false,
    "is_verified" boolean default false,
    "country_code" character varying(8) not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."roles" (
    "id" uuid not null default gen_random_uuid(),
    "name" roles_enum not null default 'customer'::roles_enum,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."social_networks" (
    "id" uuid not null default gen_random_uuid(),
    "listing_id" uuid,
    "network" character varying(50) not null,
    "url" text not null,
    "handle" character varying(255),
    "created_at" timestamp with time zone default now()
);


create table "public"."statuses" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying(20) not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."tasks" (
    "id" uuid not null default gen_random_uuid(),
    "task_uid" integer not null,
    "index_uid" character varying(100),
    "task_type" character varying(50) not null,
    "task_status" task_status_enum default 'enqueued'::task_status_enum,
    "enqueued_at" timestamp with time zone,
    "started_at" timestamp with time zone,
    "finished_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."user_addresses" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "address_id" uuid,
    "is_primary" boolean default false,
    "created_at" timestamp with time zone default now()
);


create table "public"."user_images" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "image_id" uuid,
    "created_at" timestamp with time zone default now()
);


create table "public"."user_phones" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "phone_id" uuid,
    "created_at" timestamp with time zone default now()
);


create table "public"."users" (
    "id" uuid not null default gen_random_uuid(),
    "email" character varying(255) not null,
    "role_id" uuid not null,
    "username" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


CREATE UNIQUE INDEX addresses_pkey ON public.addresses USING btree (id);

CREATE UNIQUE INDEX images_pkey ON public.images USING btree (id);

CREATE UNIQUE INDEX images_url_key ON public.images USING btree (url);

CREATE UNIQUE INDEX interactions_name_listing_id_user_id_key ON public.interactions USING btree (name, listing_id, user_id);

CREATE UNIQUE INDEX interactions_pkey ON public.interactions USING btree (id);

CREATE UNIQUE INDEX listing_images_listing_id_image_id_key ON public.listing_images USING btree (listing_id, image_id);

CREATE UNIQUE INDEX listing_images_pkey ON public.listing_images USING btree (id);

CREATE UNIQUE INDEX listing_logs_listing_id_version_key ON public.listing_logs USING btree (listing_id, version);

CREATE UNIQUE INDEX listing_logs_pkey ON public.listing_logs USING btree (id);

CREATE UNIQUE INDEX listing_phones_listing_id_phone_id_key ON public.listing_phones USING btree (listing_id, phone_id);

CREATE UNIQUE INDEX listing_phones_pkey ON public.listing_phones USING btree (id);

CREATE UNIQUE INDEX listings_name_owner_id_key ON public.listings USING btree (name, owner_id);

CREATE UNIQUE INDEX listings_pkey ON public.listings USING btree (id);

CREATE UNIQUE INDEX opening_hours_listing_id_day_of_week_key ON public.opening_hours USING btree (listing_id, day_of_week);

CREATE UNIQUE INDEX opening_hours_pkey ON public.opening_hours USING btree (id);

CREATE UNIQUE INDEX phones_number_country_code_key ON public.phones USING btree (number, country_code);

CREATE UNIQUE INDEX phones_pkey ON public.phones USING btree (id);

CREATE UNIQUE INDEX roles_name_key ON public.roles USING btree (name);

CREATE UNIQUE INDEX roles_pkey ON public.roles USING btree (id);

CREATE UNIQUE INDEX social_networks_listing_id_network_key ON public.social_networks USING btree (listing_id, network);

CREATE UNIQUE INDEX social_networks_pkey ON public.social_networks USING btree (id);

CREATE UNIQUE INDEX statuses_name_key ON public.statuses USING btree (name);

CREATE UNIQUE INDEX statuses_pkey ON public.statuses USING btree (id);

CREATE UNIQUE INDEX tasks_pkey ON public.tasks USING btree (id);

CREATE UNIQUE INDEX tasks_task_uid_key ON public.tasks USING btree (task_uid);

CREATE UNIQUE INDEX user_addresses_pkey ON public.user_addresses USING btree (id);

CREATE UNIQUE INDEX user_addresses_user_id_address_id_key ON public.user_addresses USING btree (user_id, address_id);

CREATE UNIQUE INDEX user_images_pkey ON public.user_images USING btree (id);

CREATE UNIQUE INDEX user_images_user_id_image_id_key ON public.user_images USING btree (user_id, image_id);

CREATE UNIQUE INDEX user_phones_pkey ON public.user_phones USING btree (id);

CREATE UNIQUE INDEX user_phones_user_id_phone_id_key ON public.user_phones USING btree (user_id, phone_id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

alter table "public"."addresses" add constraint "addresses_pkey" PRIMARY KEY using index "addresses_pkey";

alter table "public"."images" add constraint "images_pkey" PRIMARY KEY using index "images_pkey";

alter table "public"."interactions" add constraint "interactions_pkey" PRIMARY KEY using index "interactions_pkey";

alter table "public"."listing_images" add constraint "listing_images_pkey" PRIMARY KEY using index "listing_images_pkey";

alter table "public"."listing_logs" add constraint "listing_logs_pkey" PRIMARY KEY using index "listing_logs_pkey";

alter table "public"."listing_phones" add constraint "listing_phones_pkey" PRIMARY KEY using index "listing_phones_pkey";

alter table "public"."listings" add constraint "listings_pkey" PRIMARY KEY using index "listings_pkey";

alter table "public"."opening_hours" add constraint "opening_hours_pkey" PRIMARY KEY using index "opening_hours_pkey";

alter table "public"."phones" add constraint "phones_pkey" PRIMARY KEY using index "phones_pkey";

alter table "public"."roles" add constraint "roles_pkey" PRIMARY KEY using index "roles_pkey";

alter table "public"."social_networks" add constraint "social_networks_pkey" PRIMARY KEY using index "social_networks_pkey";

alter table "public"."statuses" add constraint "statuses_pkey" PRIMARY KEY using index "statuses_pkey";

alter table "public"."tasks" add constraint "tasks_pkey" PRIMARY KEY using index "tasks_pkey";

alter table "public"."user_addresses" add constraint "user_addresses_pkey" PRIMARY KEY using index "user_addresses_pkey";

alter table "public"."user_images" add constraint "user_images_pkey" PRIMARY KEY using index "user_images_pkey";

alter table "public"."user_phones" add constraint "user_phones_pkey" PRIMARY KEY using index "user_phones_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."images" add constraint "images_url_key" UNIQUE using index "images_url_key";

alter table "public"."interactions" add constraint "interactions_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."interactions" validate constraint "interactions_listing_id_fkey";

alter table "public"."interactions" add constraint "interactions_name_listing_id_user_id_key" UNIQUE using index "interactions_name_listing_id_user_id_key";

alter table "public"."interactions" add constraint "interactions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."interactions" validate constraint "interactions_user_id_fkey";

alter table "public"."listing_images" add constraint "listing_images_image_id_fkey" FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE CASCADE not valid;

alter table "public"."listing_images" validate constraint "listing_images_image_id_fkey";

alter table "public"."listing_images" add constraint "listing_images_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."listing_images" validate constraint "listing_images_listing_id_fkey";

alter table "public"."listing_images" add constraint "listing_images_listing_id_image_id_key" UNIQUE using index "listing_images_listing_id_image_id_key";

alter table "public"."listing_logs" add constraint "listing_logs_changed_by_id_fkey" FOREIGN KEY (changed_by_id) REFERENCES users(id) not valid;

alter table "public"."listing_logs" validate constraint "listing_logs_changed_by_id_fkey";

alter table "public"."listing_logs" add constraint "listing_logs_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."listing_logs" validate constraint "listing_logs_listing_id_fkey";

alter table "public"."listing_logs" add constraint "listing_logs_listing_id_version_key" UNIQUE using index "listing_logs_listing_id_version_key";

alter table "public"."listing_logs" add constraint "listing_logs_task_id_fkey" FOREIGN KEY (task_id) REFERENCES tasks(id) not valid;

alter table "public"."listing_logs" validate constraint "listing_logs_task_id_fkey";

alter table "public"."listing_phones" add constraint "listing_phones_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."listing_phones" validate constraint "listing_phones_listing_id_fkey";

alter table "public"."listing_phones" add constraint "listing_phones_listing_id_phone_id_key" UNIQUE using index "listing_phones_listing_id_phone_id_key";

alter table "public"."listing_phones" add constraint "listing_phones_phone_id_fkey" FOREIGN KEY (phone_id) REFERENCES phones(id) ON DELETE CASCADE not valid;

alter table "public"."listing_phones" validate constraint "listing_phones_phone_id_fkey";

alter table "public"."listings" add constraint "listings_address_id_fkey" FOREIGN KEY (address_id) REFERENCES addresses(id) not valid;

alter table "public"."listings" validate constraint "listings_address_id_fkey";

alter table "public"."listings" add constraint "listings_name_owner_id_key" UNIQUE using index "listings_name_owner_id_key";

alter table "public"."listings" add constraint "listings_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES users(id) not valid;

alter table "public"."listings" validate constraint "listings_owner_id_fkey";

alter table "public"."listings" add constraint "listings_task_id_fkey" FOREIGN KEY (task_id) REFERENCES tasks(id) not valid;

alter table "public"."listings" validate constraint "listings_task_id_fkey";

alter table "public"."opening_hours" add constraint "opening_hours_listing_id_day_of_week_key" UNIQUE using index "opening_hours_listing_id_day_of_week_key";

alter table "public"."opening_hours" add constraint "opening_hours_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."opening_hours" validate constraint "opening_hours_listing_id_fkey";

alter table "public"."phones" add constraint "phones_number_country_code_key" UNIQUE using index "phones_number_country_code_key";

alter table "public"."roles" add constraint "roles_name_key" UNIQUE using index "roles_name_key";

alter table "public"."social_networks" add constraint "social_networks_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."social_networks" validate constraint "social_networks_listing_id_fkey";

alter table "public"."social_networks" add constraint "social_networks_listing_id_network_key" UNIQUE using index "social_networks_listing_id_network_key";

alter table "public"."statuses" add constraint "statuses_name_key" UNIQUE using index "statuses_name_key";

alter table "public"."tasks" add constraint "tasks_task_uid_key" UNIQUE using index "tasks_task_uid_key";

alter table "public"."user_addresses" add constraint "user_addresses_address_id_fkey" FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE CASCADE not valid;

alter table "public"."user_addresses" validate constraint "user_addresses_address_id_fkey";

alter table "public"."user_addresses" add constraint "user_addresses_user_id_address_id_key" UNIQUE using index "user_addresses_user_id_address_id_key";

alter table "public"."user_addresses" add constraint "user_addresses_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."user_addresses" validate constraint "user_addresses_user_id_fkey";

alter table "public"."user_images" add constraint "user_images_image_id_fkey" FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE CASCADE not valid;

alter table "public"."user_images" validate constraint "user_images_image_id_fkey";

alter table "public"."user_images" add constraint "user_images_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."user_images" validate constraint "user_images_user_id_fkey";

alter table "public"."user_images" add constraint "user_images_user_id_image_id_key" UNIQUE using index "user_images_user_id_image_id_key";

alter table "public"."user_phones" add constraint "user_phones_phone_id_fkey" FOREIGN KEY (phone_id) REFERENCES phones(id) ON DELETE CASCADE not valid;

alter table "public"."user_phones" validate constraint "user_phones_phone_id_fkey";

alter table "public"."user_phones" add constraint "user_phones_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."user_phones" validate constraint "user_phones_user_id_fkey";

alter table "public"."user_phones" add constraint "user_phones_user_id_phone_id_key" UNIQUE using index "user_phones_user_id_phone_id_key";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) not valid;

alter table "public"."users" validate constraint "users_role_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_user(user_id uuid, email text, password text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
SELECT EXISTS (SELECT 1
               FROM users p
                        JOIN roles r ON p.role_id = r.id
               WHERE p.id = auth.uid()
                 AND r.name = 'admin');
$function$
;

grant delete on table "public"."addresses" to "anon";

grant insert on table "public"."addresses" to "anon";

grant references on table "public"."addresses" to "anon";

grant select on table "public"."addresses" to "anon";

grant trigger on table "public"."addresses" to "anon";

grant truncate on table "public"."addresses" to "anon";

grant update on table "public"."addresses" to "anon";

grant delete on table "public"."addresses" to "authenticated";

grant insert on table "public"."addresses" to "authenticated";

grant references on table "public"."addresses" to "authenticated";

grant select on table "public"."addresses" to "authenticated";

grant trigger on table "public"."addresses" to "authenticated";

grant truncate on table "public"."addresses" to "authenticated";

grant update on table "public"."addresses" to "authenticated";

grant delete on table "public"."addresses" to "service_role";

grant insert on table "public"."addresses" to "service_role";

grant references on table "public"."addresses" to "service_role";

grant select on table "public"."addresses" to "service_role";

grant trigger on table "public"."addresses" to "service_role";

grant truncate on table "public"."addresses" to "service_role";

grant update on table "public"."addresses" to "service_role";

grant delete on table "public"."images" to "anon";

grant insert on table "public"."images" to "anon";

grant references on table "public"."images" to "anon";

grant select on table "public"."images" to "anon";

grant trigger on table "public"."images" to "anon";

grant truncate on table "public"."images" to "anon";

grant update on table "public"."images" to "anon";

grant delete on table "public"."images" to "authenticated";

grant insert on table "public"."images" to "authenticated";

grant references on table "public"."images" to "authenticated";

grant select on table "public"."images" to "authenticated";

grant trigger on table "public"."images" to "authenticated";

grant truncate on table "public"."images" to "authenticated";

grant update on table "public"."images" to "authenticated";

grant delete on table "public"."images" to "service_role";

grant insert on table "public"."images" to "service_role";

grant references on table "public"."images" to "service_role";

grant select on table "public"."images" to "service_role";

grant trigger on table "public"."images" to "service_role";

grant truncate on table "public"."images" to "service_role";

grant update on table "public"."images" to "service_role";

grant delete on table "public"."interactions" to "anon";

grant insert on table "public"."interactions" to "anon";

grant references on table "public"."interactions" to "anon";

grant select on table "public"."interactions" to "anon";

grant trigger on table "public"."interactions" to "anon";

grant truncate on table "public"."interactions" to "anon";

grant update on table "public"."interactions" to "anon";

grant delete on table "public"."interactions" to "authenticated";

grant insert on table "public"."interactions" to "authenticated";

grant references on table "public"."interactions" to "authenticated";

grant select on table "public"."interactions" to "authenticated";

grant trigger on table "public"."interactions" to "authenticated";

grant truncate on table "public"."interactions" to "authenticated";

grant update on table "public"."interactions" to "authenticated";

grant delete on table "public"."interactions" to "service_role";

grant insert on table "public"."interactions" to "service_role";

grant references on table "public"."interactions" to "service_role";

grant select on table "public"."interactions" to "service_role";

grant trigger on table "public"."interactions" to "service_role";

grant truncate on table "public"."interactions" to "service_role";

grant update on table "public"."interactions" to "service_role";

grant delete on table "public"."listing_images" to "anon";

grant insert on table "public"."listing_images" to "anon";

grant references on table "public"."listing_images" to "anon";

grant select on table "public"."listing_images" to "anon";

grant trigger on table "public"."listing_images" to "anon";

grant truncate on table "public"."listing_images" to "anon";

grant update on table "public"."listing_images" to "anon";

grant delete on table "public"."listing_images" to "authenticated";

grant insert on table "public"."listing_images" to "authenticated";

grant references on table "public"."listing_images" to "authenticated";

grant select on table "public"."listing_images" to "authenticated";

grant trigger on table "public"."listing_images" to "authenticated";

grant truncate on table "public"."listing_images" to "authenticated";

grant update on table "public"."listing_images" to "authenticated";

grant delete on table "public"."listing_images" to "service_role";

grant insert on table "public"."listing_images" to "service_role";

grant references on table "public"."listing_images" to "service_role";

grant select on table "public"."listing_images" to "service_role";

grant trigger on table "public"."listing_images" to "service_role";

grant truncate on table "public"."listing_images" to "service_role";

grant update on table "public"."listing_images" to "service_role";

grant delete on table "public"."listing_logs" to "anon";

grant insert on table "public"."listing_logs" to "anon";

grant references on table "public"."listing_logs" to "anon";

grant select on table "public"."listing_logs" to "anon";

grant trigger on table "public"."listing_logs" to "anon";

grant truncate on table "public"."listing_logs" to "anon";

grant update on table "public"."listing_logs" to "anon";

grant delete on table "public"."listing_logs" to "authenticated";

grant insert on table "public"."listing_logs" to "authenticated";

grant references on table "public"."listing_logs" to "authenticated";

grant select on table "public"."listing_logs" to "authenticated";

grant trigger on table "public"."listing_logs" to "authenticated";

grant truncate on table "public"."listing_logs" to "authenticated";

grant update on table "public"."listing_logs" to "authenticated";

grant delete on table "public"."listing_logs" to "service_role";

grant insert on table "public"."listing_logs" to "service_role";

grant references on table "public"."listing_logs" to "service_role";

grant select on table "public"."listing_logs" to "service_role";

grant trigger on table "public"."listing_logs" to "service_role";

grant truncate on table "public"."listing_logs" to "service_role";

grant update on table "public"."listing_logs" to "service_role";

grant delete on table "public"."listing_phones" to "anon";

grant insert on table "public"."listing_phones" to "anon";

grant references on table "public"."listing_phones" to "anon";

grant select on table "public"."listing_phones" to "anon";

grant trigger on table "public"."listing_phones" to "anon";

grant truncate on table "public"."listing_phones" to "anon";

grant update on table "public"."listing_phones" to "anon";

grant delete on table "public"."listing_phones" to "authenticated";

grant insert on table "public"."listing_phones" to "authenticated";

grant references on table "public"."listing_phones" to "authenticated";

grant select on table "public"."listing_phones" to "authenticated";

grant trigger on table "public"."listing_phones" to "authenticated";

grant truncate on table "public"."listing_phones" to "authenticated";

grant update on table "public"."listing_phones" to "authenticated";

grant delete on table "public"."listing_phones" to "service_role";

grant insert on table "public"."listing_phones" to "service_role";

grant references on table "public"."listing_phones" to "service_role";

grant select on table "public"."listing_phones" to "service_role";

grant trigger on table "public"."listing_phones" to "service_role";

grant truncate on table "public"."listing_phones" to "service_role";

grant update on table "public"."listing_phones" to "service_role";

grant delete on table "public"."listings" to "anon";

grant insert on table "public"."listings" to "anon";

grant references on table "public"."listings" to "anon";

grant select on table "public"."listings" to "anon";

grant trigger on table "public"."listings" to "anon";

grant truncate on table "public"."listings" to "anon";

grant update on table "public"."listings" to "anon";

grant delete on table "public"."listings" to "authenticated";

grant insert on table "public"."listings" to "authenticated";

grant references on table "public"."listings" to "authenticated";

grant select on table "public"."listings" to "authenticated";

grant trigger on table "public"."listings" to "authenticated";

grant truncate on table "public"."listings" to "authenticated";

grant update on table "public"."listings" to "authenticated";

grant delete on table "public"."listings" to "service_role";

grant insert on table "public"."listings" to "service_role";

grant references on table "public"."listings" to "service_role";

grant select on table "public"."listings" to "service_role";

grant trigger on table "public"."listings" to "service_role";

grant truncate on table "public"."listings" to "service_role";

grant update on table "public"."listings" to "service_role";

grant delete on table "public"."opening_hours" to "anon";

grant insert on table "public"."opening_hours" to "anon";

grant references on table "public"."opening_hours" to "anon";

grant select on table "public"."opening_hours" to "anon";

grant trigger on table "public"."opening_hours" to "anon";

grant truncate on table "public"."opening_hours" to "anon";

grant update on table "public"."opening_hours" to "anon";

grant delete on table "public"."opening_hours" to "authenticated";

grant insert on table "public"."opening_hours" to "authenticated";

grant references on table "public"."opening_hours" to "authenticated";

grant select on table "public"."opening_hours" to "authenticated";

grant trigger on table "public"."opening_hours" to "authenticated";

grant truncate on table "public"."opening_hours" to "authenticated";

grant update on table "public"."opening_hours" to "authenticated";

grant delete on table "public"."opening_hours" to "service_role";

grant insert on table "public"."opening_hours" to "service_role";

grant references on table "public"."opening_hours" to "service_role";

grant select on table "public"."opening_hours" to "service_role";

grant trigger on table "public"."opening_hours" to "service_role";

grant truncate on table "public"."opening_hours" to "service_role";

grant update on table "public"."opening_hours" to "service_role";

grant delete on table "public"."phones" to "anon";

grant insert on table "public"."phones" to "anon";

grant references on table "public"."phones" to "anon";

grant select on table "public"."phones" to "anon";

grant trigger on table "public"."phones" to "anon";

grant truncate on table "public"."phones" to "anon";

grant update on table "public"."phones" to "anon";

grant delete on table "public"."phones" to "authenticated";

grant insert on table "public"."phones" to "authenticated";

grant references on table "public"."phones" to "authenticated";

grant select on table "public"."phones" to "authenticated";

grant trigger on table "public"."phones" to "authenticated";

grant truncate on table "public"."phones" to "authenticated";

grant update on table "public"."phones" to "authenticated";

grant delete on table "public"."phones" to "service_role";

grant insert on table "public"."phones" to "service_role";

grant references on table "public"."phones" to "service_role";

grant select on table "public"."phones" to "service_role";

grant trigger on table "public"."phones" to "service_role";

grant truncate on table "public"."phones" to "service_role";

grant update on table "public"."phones" to "service_role";

grant delete on table "public"."roles" to "anon";

grant insert on table "public"."roles" to "anon";

grant references on table "public"."roles" to "anon";

grant select on table "public"."roles" to "anon";

grant trigger on table "public"."roles" to "anon";

grant truncate on table "public"."roles" to "anon";

grant update on table "public"."roles" to "anon";

grant delete on table "public"."roles" to "authenticated";

grant insert on table "public"."roles" to "authenticated";

grant references on table "public"."roles" to "authenticated";

grant select on table "public"."roles" to "authenticated";

grant trigger on table "public"."roles" to "authenticated";

grant truncate on table "public"."roles" to "authenticated";

grant update on table "public"."roles" to "authenticated";

grant delete on table "public"."roles" to "service_role";

grant insert on table "public"."roles" to "service_role";

grant references on table "public"."roles" to "service_role";

grant select on table "public"."roles" to "service_role";

grant trigger on table "public"."roles" to "service_role";

grant truncate on table "public"."roles" to "service_role";

grant update on table "public"."roles" to "service_role";

grant delete on table "public"."social_networks" to "anon";

grant insert on table "public"."social_networks" to "anon";

grant references on table "public"."social_networks" to "anon";

grant select on table "public"."social_networks" to "anon";

grant trigger on table "public"."social_networks" to "anon";

grant truncate on table "public"."social_networks" to "anon";

grant update on table "public"."social_networks" to "anon";

grant delete on table "public"."social_networks" to "authenticated";

grant insert on table "public"."social_networks" to "authenticated";

grant references on table "public"."social_networks" to "authenticated";

grant select on table "public"."social_networks" to "authenticated";

grant trigger on table "public"."social_networks" to "authenticated";

grant truncate on table "public"."social_networks" to "authenticated";

grant update on table "public"."social_networks" to "authenticated";

grant delete on table "public"."social_networks" to "service_role";

grant insert on table "public"."social_networks" to "service_role";

grant references on table "public"."social_networks" to "service_role";

grant select on table "public"."social_networks" to "service_role";

grant trigger on table "public"."social_networks" to "service_role";

grant truncate on table "public"."social_networks" to "service_role";

grant update on table "public"."social_networks" to "service_role";

grant delete on table "public"."statuses" to "anon";

grant insert on table "public"."statuses" to "anon";

grant references on table "public"."statuses" to "anon";

grant select on table "public"."statuses" to "anon";

grant trigger on table "public"."statuses" to "anon";

grant truncate on table "public"."statuses" to "anon";

grant update on table "public"."statuses" to "anon";

grant delete on table "public"."statuses" to "authenticated";

grant insert on table "public"."statuses" to "authenticated";

grant references on table "public"."statuses" to "authenticated";

grant select on table "public"."statuses" to "authenticated";

grant trigger on table "public"."statuses" to "authenticated";

grant truncate on table "public"."statuses" to "authenticated";

grant update on table "public"."statuses" to "authenticated";

grant delete on table "public"."statuses" to "service_role";

grant insert on table "public"."statuses" to "service_role";

grant references on table "public"."statuses" to "service_role";

grant select on table "public"."statuses" to "service_role";

grant trigger on table "public"."statuses" to "service_role";

grant truncate on table "public"."statuses" to "service_role";

grant update on table "public"."statuses" to "service_role";

grant delete on table "public"."tasks" to "anon";

grant insert on table "public"."tasks" to "anon";

grant references on table "public"."tasks" to "anon";

grant select on table "public"."tasks" to "anon";

grant trigger on table "public"."tasks" to "anon";

grant truncate on table "public"."tasks" to "anon";

grant update on table "public"."tasks" to "anon";

grant delete on table "public"."tasks" to "authenticated";

grant insert on table "public"."tasks" to "authenticated";

grant references on table "public"."tasks" to "authenticated";

grant select on table "public"."tasks" to "authenticated";

grant trigger on table "public"."tasks" to "authenticated";

grant truncate on table "public"."tasks" to "authenticated";

grant update on table "public"."tasks" to "authenticated";

grant delete on table "public"."tasks" to "service_role";

grant insert on table "public"."tasks" to "service_role";

grant references on table "public"."tasks" to "service_role";

grant select on table "public"."tasks" to "service_role";

grant trigger on table "public"."tasks" to "service_role";

grant truncate on table "public"."tasks" to "service_role";

grant update on table "public"."tasks" to "service_role";

grant delete on table "public"."user_addresses" to "anon";

grant insert on table "public"."user_addresses" to "anon";

grant references on table "public"."user_addresses" to "anon";

grant select on table "public"."user_addresses" to "anon";

grant trigger on table "public"."user_addresses" to "anon";

grant truncate on table "public"."user_addresses" to "anon";

grant update on table "public"."user_addresses" to "anon";

grant delete on table "public"."user_addresses" to "authenticated";

grant insert on table "public"."user_addresses" to "authenticated";

grant references on table "public"."user_addresses" to "authenticated";

grant select on table "public"."user_addresses" to "authenticated";

grant trigger on table "public"."user_addresses" to "authenticated";

grant truncate on table "public"."user_addresses" to "authenticated";

grant update on table "public"."user_addresses" to "authenticated";

grant delete on table "public"."user_addresses" to "service_role";

grant insert on table "public"."user_addresses" to "service_role";

grant references on table "public"."user_addresses" to "service_role";

grant select on table "public"."user_addresses" to "service_role";

grant trigger on table "public"."user_addresses" to "service_role";

grant truncate on table "public"."user_addresses" to "service_role";

grant update on table "public"."user_addresses" to "service_role";

grant delete on table "public"."user_images" to "anon";

grant insert on table "public"."user_images" to "anon";

grant references on table "public"."user_images" to "anon";

grant select on table "public"."user_images" to "anon";

grant trigger on table "public"."user_images" to "anon";

grant truncate on table "public"."user_images" to "anon";

grant update on table "public"."user_images" to "anon";

grant delete on table "public"."user_images" to "authenticated";

grant insert on table "public"."user_images" to "authenticated";

grant references on table "public"."user_images" to "authenticated";

grant select on table "public"."user_images" to "authenticated";

grant trigger on table "public"."user_images" to "authenticated";

grant truncate on table "public"."user_images" to "authenticated";

grant update on table "public"."user_images" to "authenticated";

grant delete on table "public"."user_images" to "service_role";

grant insert on table "public"."user_images" to "service_role";

grant references on table "public"."user_images" to "service_role";

grant select on table "public"."user_images" to "service_role";

grant trigger on table "public"."user_images" to "service_role";

grant truncate on table "public"."user_images" to "service_role";

grant update on table "public"."user_images" to "service_role";

grant delete on table "public"."user_phones" to "anon";

grant insert on table "public"."user_phones" to "anon";

grant references on table "public"."user_phones" to "anon";

grant select on table "public"."user_phones" to "anon";

grant trigger on table "public"."user_phones" to "anon";

grant truncate on table "public"."user_phones" to "anon";

grant update on table "public"."user_phones" to "anon";

grant delete on table "public"."user_phones" to "authenticated";

grant insert on table "public"."user_phones" to "authenticated";

grant references on table "public"."user_phones" to "authenticated";

grant select on table "public"."user_phones" to "authenticated";

grant trigger on table "public"."user_phones" to "authenticated";

grant truncate on table "public"."user_phones" to "authenticated";

grant update on table "public"."user_phones" to "authenticated";

grant delete on table "public"."user_phones" to "service_role";

grant insert on table "public"."user_phones" to "service_role";

grant references on table "public"."user_phones" to "service_role";

grant select on table "public"."user_phones" to "service_role";

grant trigger on table "public"."user_phones" to "service_role";

grant truncate on table "public"."user_phones" to "service_role";

grant update on table "public"."user_phones" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";


