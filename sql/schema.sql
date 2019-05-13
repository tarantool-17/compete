/* ===================   Auth   =================== */

CREATE SCHEMA auth;

create table if not exists auth.roles
(
    id serial not null constraint pk_roles primary key,
    name              varchar(256),
    normalized_name   varchar(256),
    concurrency_stamp text
);

create unique index if not exists role_name_index
    on auth.roles (normalized_name);

create table if not exists auth.users
(
    id serial not null constraint pk_users primary key,
    user_name              varchar(256),
    normalized_user_name   varchar(256),
    email                  varchar(256),
    normalized_email       varchar(256),
    email_confirmed        boolean not null,
    password_hash          text,
    security_stamp         text,
    concurrency_stamp      text,
    phone_number           text,
    phone_number_confirmed boolean not null,
    two_factor_enabled     boolean not null,
    lockout_end            timestamp with time zone,
    lockout_enabled        boolean not null,
    access_failed_count    integer not null
);

create index if not exists email_index
    on auth.users (normalized_email);

create unique index if not exists user_name_index
    on auth.users (normalized_user_name);

create table if not exists auth.role_claim
(
    id serial not null constraint pk_role_claim primary key,
    role_id integer not null constraint fk_role_claim_roles_role_id references auth.roles on delete cascade,
    claim_type  text,
    claim_value text
);

create index if not exists ix_role_claim_role_id
    on auth.role_claim (role_id);

create table if not exists auth.user_claim
(
    id serial not null constraint pk_user_claim primary key,
    user_id integer not null constraint fk_user_claim_users_user_id references auth.users on delete cascade,
    claim_type  text,
    claim_value text
);

create index if not exists ix_user_claim_user_id
    on auth.user_claim (user_id);

create table if not exists auth.user_login
(
    login_provider        text    not null,
    provider_key          text    not null,
    provider_display_name text,
    user_id integer not null constraint fk_user_login_users_user_id references auth.users on delete cascade,
    constraint pk_user_login primary key (login_provider, provider_key)
);

create index if not exists ix_user_login_user_id
    on auth.user_login (user_id);

create table if not exists auth.user_role
(
    user_id integer not null constraint fk_user_role_users_user_id references auth.users on delete cascade,
    role_id integer not null constraint fk_user_role_roles_role_id references auth.roles on delete cascade,
    constraint pk_user_role primary key (user_id, role_id)
);

create index if not exists ix_user_role_role_id
    on auth.user_role (role_id);

create table if not exists auth.user_token
(
    user_id integer not null constraint fk_user_token_users_user_id references auth.users on delete cascade,
    login_provider text    not null,
    name           text    not null,
    value          text,
    constraint pk_user_token primary key (user_id, login_provider, name)
);


/* ===================   Public   =================== */

CREATE TABLE if not exists "countries" (
  "code" varchar PRIMARY KEY,
  "name" varchar
);

CREATE TABLE if not exists "profile" (
  "id" serial not null constraint pk_profile primary key,
  "name" varchar,
  "weight" decimal,
  "date_of_birth" timestamp with time zone,
  "club_id" int,
  "user_id" int not null constraint fk_profile_users_id  references auth.users on delete cascade,
  "country_code" varchar
);

CREATE TABLE if not exists "competition" (
  "id" serial not null constraint pk_competition primary key,
  "title" varchar
);

CREATE TABLE if not exists "category" (
  "id" serial not null constraint pk_category primary key,
  "competition_id" integer,
  "sex" boolean,
  "min_age" integer,
  "max_age" integer,
  "min_weight" decimal,
  "max_weight" decimal
);

CREATE TABLE if not exists "club" (
  "id" serial not null constraint pk_club primary key,
  "name" varchar
);

CREATE TABLE if not exists "participant" (
  "id" serial not null constraint pk_participant primary key,
  "competition_id" int,
  "profile_id" int
);

CREATE TABLE if not exists "participant_category" (
  "category_id" integer,
  "participant_id" integer,
  PRIMARY KEY (category_id, participant_id)
);

ALTER TABLE "participant" ADD FOREIGN KEY ("competition_id") REFERENCES "competition" ("id");

ALTER TABLE "participant" ADD FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "category" ADD FOREIGN KEY ("competition_id") REFERENCES "competition" ("id");

ALTER TABLE "profile" ADD FOREIGN KEY ("country_code") REFERENCES "countries" ("code");

ALTER TABLE "profile" ADD FOREIGN KEY ("club_id") REFERENCES "club" ("id");

ALTER TABLE "participant_category" ADD FOREIGN KEY ("category_id") REFERENCES "category" ("id");

ALTER TABLE "participant_category" ADD FOREIGN KEY ("participant_id") REFERENCES "participant" ("id");


/* ===================   Functions   =================== */

CREATE OR REPLACE FUNCTION insert_form(title TEXT, questions TEXT[]) 
RETURNS void AS $$ 
DECLARE
    form_id INTEGER;
    question TEXT;
BEGIN 

INSERT INTO form (title) VALUES (title);

form_id := lastval();

FOREACH question IN ARRAY questions
LOOP
    INSERT INTO question (form_id, body) VALUES
    (form_id, question)
    ON CONFLICT DO NOTHING;

END LOOP;

END $$ LANGUAGE plpgsql; 