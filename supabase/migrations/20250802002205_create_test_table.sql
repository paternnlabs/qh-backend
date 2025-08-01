create table "public"."test" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying(255) not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


CREATE UNIQUE INDEX test_pkey ON public.test USING btree (id);

alter table "public"."test" add constraint "test_pkey" PRIMARY KEY using index "test_pkey";

grant delete on table "public"."test" to "anon";

grant insert on table "public"."test" to "anon";

grant references on table "public"."test" to "anon";

grant select on table "public"."test" to "anon";

grant trigger on table "public"."test" to "anon";

grant truncate on table "public"."test" to "anon";

grant update on table "public"."test" to "anon";

grant delete on table "public"."test" to "authenticated";

grant insert on table "public"."test" to "authenticated";

grant references on table "public"."test" to "authenticated";

grant select on table "public"."test" to "authenticated";

grant trigger on table "public"."test" to "authenticated";

grant truncate on table "public"."test" to "authenticated";

grant update on table "public"."test" to "authenticated";

grant delete on table "public"."test" to "service_role";

grant insert on table "public"."test" to "service_role";

grant references on table "public"."test" to "service_role";

grant select on table "public"."test" to "service_role";

grant trigger on table "public"."test" to "service_role";

grant truncate on table "public"."test" to "service_role";

grant update on table "public"."test" to "service_role";


