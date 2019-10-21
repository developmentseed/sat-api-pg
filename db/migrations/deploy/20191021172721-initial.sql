
--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2 (Debian 11.2-1.pgdg90+1)
-- Dumped by pg_dump version 11.4

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

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA api;



--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA auth;



--
-- Name: data; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA data;



--
-- Name: pgjwt; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA pgjwt;



--
-- Name: request; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA request;



--
-- Name: settings; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA settings;

-- load some variables from the env
\setenv base_dir :DIR
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set anonymous `echo $DB_ANON_ROLE`
\set authenticator `echo $DB_USER`
\set authenticator_pass `echo $DB_PASS`
\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''

DROP ROLE IF EXISTS api;
CREATE ROLE api;
GRANT api to current_user; -- this is a workaround for RDS where the master user does not have SUPERUSER priviliges  

DROP ROLE IF EXISTS webuser;
CREATE ROLE webuser;

drop role if exists :authenticator;
create role :"authenticator" with login password :'authenticator_pass';

drop role if exists :"anonymous";
create role :"anonymous";
grant :"anonymous" to :"authenticator";

drop role if exists application;
create role application;
grant application to :"authenticator";

--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA data;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--



--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--



--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA data;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--



--
-- Name: session; Type: TYPE; Schema: api; Owner: superuser
--

CREATE TYPE api.session AS (
	me json,
	token text
);



--
-- Name: user; Type: TYPE; Schema: api; Owner: superuser
--

CREATE TYPE api."user" AS (
	id integer,
	name text,
	email text,
	role text
);



--
-- Name: linkobject; Type: TYPE; Schema: data; Owner: superuser
--

CREATE TYPE data.linkobject AS (
	href character varying(1024),
	rel character varying(1024),
	type character varying(1024),
	title character varying(1024)
);



--
-- Name: user_role; Type: TYPE; Schema: data; Owner: superuser
--

CREATE TYPE data.user_role AS ENUM (
    'webuser'
);



--
-- Name: login(text, text); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.login(email text, password text) RETURNS api.session
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
    usr record;
    usr_api record;
    result record;
begin

    EXECUTE format(
		' select row_to_json(u.*) as j'
        ' from %I."user" as u'
        ' where u.email = $1 and u.password = public.crypt($2, u.password)'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING $1, $2;

    if usr is NULL then
        raise exception 'invalid email/password';
    else
        EXECUTE format(
            ' select json_populate_record(null::%I."user", $1) as r'
		    , quote_ident(settings.get('auth.api-schema')))
   	    INTO usr_api
	    USING usr.j;

        result = (
            row_to_json(usr_api.r),
            auth.sign_jwt(auth.get_jwt_payload(usr.j))
        );
        return result;
    end if;
end
$_$;



--
-- Name: me(); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.me() RETURNS api."user"
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
	usr record;
begin
	
	EXECUTE format(
		' select row_to_json(u.*) as j'
		' from %I."user" as u'
		' where id = $1'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING request.user_id();

	EXECUTE format(
		'select json_populate_record(null::%I."user", $1) as r'
		, quote_ident(settings.get('auth.api-schema')))
   	INTO usr
	USING usr.j;

	return usr.r;
end
$_$;



--
-- Name: refresh_token(); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.refresh_token() RETURNS text
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
	usr record;
	token text;
begin

    EXECUTE format(
		' select row_to_json(u.*) as j'
        ' from %I."user" as u'
        ' where u.id = $1'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING request.user_id();

    if usr is NULL then
    	raise exception 'user not found';
    else
    	select auth.sign_jwt(auth.get_jwt_payload(usr.j))
    	into token;
    	return token;
    end if;
end
$_$;



SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: apiurls; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.apiurls (
    url character varying(1024)
);



--
-- Name: collections; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.collections (
    id character varying(1024) NOT NULL,
    title character varying(1024),
    description character varying(1024) NOT NULL,
    keywords character varying(300)[],
    version character varying(300),
    license character varying(300) NOT NULL,
    providers jsonb[],
    extent jsonb,
    properties jsonb,
    links data.linkobject[]
);



--
-- Name: items; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.items (
    id character varying(1024) NOT NULL,
    type character varying(20) NOT NULL,
    geometry data.geometry NOT NULL,
    bbox numeric[] NOT NULL,
    properties jsonb NOT NULL,
    assets jsonb NOT NULL,
    collection character varying(1024),
    datetime timestamp with time zone NOT NULL,
    links data.linkobject[]
);



--
-- Name: itemslinks; Type: VIEW; Schema: data; Owner: superuser
--

CREATE VIEW data.itemslinks AS
 SELECT i.id,
    i.type,
    i.geometry,
    i.bbox,
    i.properties,
    i.assets,
    i.collection,
    i.datetime,
    '0.8.0'::text AS stac_version,
    ( SELECT array_cat(ARRAY[ROW((( SELECT (((((apiurls.url)::text || '/collections/'::text) || (i.collection)::text) || '/'::text) || (i.id)::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'self'::character varying(1024), 'application/geo+json'::character varying(1024), NULL::character varying(1024))::data.linkobject, ROW((( SELECT (((apiurls.url)::text || '/collections/'::text) || (i.collection)::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'parent'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject], i.links) AS array_cat) AS links
   FROM data.items i;



--
-- Name: collectionitems; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.collectionitems AS
 SELECT c.properties AS collectionproperties,
    i.collection,
    i.id,
    i.geometry AS geom,
    i.bbox,
    i.type,
    i.assets,
    (data.st_asgeojson(i.geometry))::json AS geometry,
    i.properties,
    i.datetime,
    i.links,
    i.stac_version
   FROM (data.itemslinks i
     RIGHT JOIN data.collections c ON (((i.collection)::text = (c.id)::text)));


ALTER TABLE api.collectionitems OWNER TO api;

--
-- Name: search(numeric[], json, text[]); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.search(bbox numeric[] DEFAULT NULL::numeric[], intersects json DEFAULT NULL::json, include text[] DEFAULT NULL::text[]) RETURNS SETOF api.collectionitems
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  intersects_geometry data.geometry;
BEGIN
  IF bbox IS NOT NULL THEN
    intersects_geometry = data.ST_MakeEnvelope(
      bbox[1],
      bbox[2],
      bbox[3],
      bbox[4],
      4326
    );
  ELSIF intersects IS NOT NULL THEN
    intersects_geometry = data.st_SetSRID(data.ST_GeomFromGeoJSON(intersects), 4326);
  END IF;
  IF include IS NOT NULL THEN
    RETURN QUERY
    SELECT
    collectionproperties,
    collection,
    id,
    geom,
    bbox,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
      from jsonb_each(properties) e
      where e.key = ANY (include)) properties,
    datetime,
    links,
    stac_version
    FROM collectionitems
    WHERE data.ST_INTERSECTS(collectionitems.geom, intersects_geometry);
  ELSE
    RETURN QUERY
    SELECT *
    FROM collectionitems
    WHERE data.ST_INTERSECTS(collectionitems.geom, intersects_geometry);
  END IF;
END
$$;



--
-- Name: searchnogeom(text[]); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.searchnogeom(include text[] DEFAULT NULL::text[]) RETURNS SETOF api.collectionitems
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF include IS NOT NULL THEN
    RETURN QUERY
    SELECT
    collectionproperties,
    collection,
    id,
    geom,
    bbox,
    type,
    assets,
    geometry,
    (select jsonb_object_agg(e.key, e.value)
      from jsonb_each(properties) e
      where e.key = ANY (include)) properties,
    datetime,
    links,
    stac_version
    FROM collectionitems;
  ELSE
    RETURN QUERY
    SELECT *
    FROM collectionitems;
  END IF;
END
$$;



--
-- Name: signup(text, text, text); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.signup(name text, email text, password text) RETURNS api.session
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
declare
    usr record;
    result record;
    usr_api record;
begin
    EXECUTE format(
        ' insert into %I."user" as u'
        ' (name, email, password) values'
        ' ($1, $2, $3)'
        ' returning row_to_json(u.*) as j'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING $1, $2, $3;

    EXECUTE format(
        ' select json_populate_record(null::%I."user", $1) as r'
        , quote_ident(settings.get('auth.api-schema')))
    INTO usr_api
    USING usr.j;

    result := (
        row_to_json(usr_api.r),
        auth.sign_jwt(auth.get_jwt_payload(usr.j))
    );

    return result;
end
$_$;



--
-- Name: encrypt_pass(); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.encrypt_pass() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if new.password is not null then
  	new.password = public.crypt(new.password, public.gen_salt('bf'));
  end if;
  return new;
end
$$;



--
-- Name: get_jwt_payload(json); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.get_jwt_payload(json) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
    select json_build_object(
                'role', $1->'role',
                'user_id', $1->'id',
                'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int -- token expires in 1 hour
            )
$_$;



--
-- Name: set_auth_endpoints_privileges(text, text, text[]); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.set_auth_endpoints_privileges(schema text, anonymous text, roles text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare r record;
begin
  execute 'grant execute on function ' || quote_ident(schema) || '.login(text,text) to ' || quote_ident(anonymous);
  execute 'grant execute on function ' || quote_ident(schema) || '.signup(text,text,text) to ' || quote_ident(anonymous);
  for r in
     select unnest(roles) as role
  loop
     execute 'grant execute on function ' || quote_ident(schema) || '.me() to ' || quote_ident(r.role);
     execute 'grant execute on function ' || quote_ident(schema) || '.login(text,text) to ' || quote_ident(r.role);
     execute 'grant execute on function ' || quote_ident(schema) || '.refresh_token() to ' || quote_ident(r.role);
  end loop;
end;
$$;



--
-- Name: sign_jwt(json); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.sign_jwt(json) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
    select pgjwt.sign($1, settings.get('jwt_secret'))
$_$;



--
-- Name: convert_collection_links(); Type: FUNCTION; Schema: data; Owner: superuser
--

CREATE FUNCTION data.convert_collection_links() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    newlinks data.linkobject;
    filteredlinks data.linkobject[];
  BEGIN
  SELECT * INTO newlinks FROM unnest(new.links) as linkObj
  WHERE linkObj.rel = 'derived_from';
  IF newlinks.href IS NOT NULL THEN
    filteredlinks = ARRAY[newlinks];
  ELSE
    filteredlinks = NULL;
  END IF;
  INSERT INTO data.collections(
    id,
    title,
    description,
    keywords,
    version,
    license,
    providers,
    extent,
    properties,
    links
  )
  VALUES(
    new.id,
    new.title,
    new.description,
    new.keywords,
    new.version,
    new.license,
    new.providers,
    new.extent,
    new.properties,
    filteredlinks
  );
  RETURN NEW;
  END;
  $$;



--
-- Name: convert_values(); Type: FUNCTION; Schema: data; Owner: superuser
--

CREATE FUNCTION data.convert_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    converted_geometry data.geometry;
    converted_datetime timestamp with time zone;
    newlinks data.linkobject;
    filteredlinks data.linkobject[];
  BEGIN
    --  IF TG_OP = 'INSERT' AND (NEW.geometry ISNULL) THEN
      --  RAISE EXCEPTION 'geometry is required';
      --  RETURN NULL;
    --  END IF;
  --  EXCEPTION WHEN SQLSTATE 'XX000' THEN
    --  RAISE WARNING 'geometry not updated: %', SQLERRM;
  converted_geometry = data.st_setsrid(data.ST_GeomFromGeoJSON(NEW.geometry), 4326);
  converted_datetime = (new.properties)->'datetime';
  SELECT * INTO newlinks FROM unnest(new.links) as linkObj
  WHERE linkObj.rel = 'derived_from';
  IF newlinks.href IS NOT NULL THEN
    filteredlinks = ARRAY[newlinks];
  ELSE
    filteredlinks = NULL;
  END IF;
  INSERT INTO data.items(
    id,
    type,
    geometry,
    bbox,
    properties,
    assets,
    collection,
    datetime,
    links)
  VALUES(
    new.id,
    new.type,
    converted_geometry,
    new.bbox,
    new.properties,
    new.assets,
    new.collection,
    converted_datetime,
    filteredlinks);
  RETURN NEW;
  END;
  $$;



--
-- Name: algorithm_sign(text, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.algorithm_sign(signables text, secret text, algorithm text) RETURNS text
    LANGUAGE sql
    AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END)  -- hmac throws error
SELECT pgjwt.url_encode(public.hmac(signables, secret, (select * FROM alg)));
$$;



--
-- Name: sign(json, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.sign(payload json, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS text
    LANGUAGE sql
    AS $$
WITH
  header AS (
    SELECT pgjwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8'))
    ),
  payload AS (
    SELECT pgjwt.url_encode(convert_to(payload::text, 'utf8'))
    ),
  signables AS (
    SELECT (SELECT * FROM header) || '.' || (SELECT * FROM payload)
    )
SELECT
    (SELECT * FROM signables)
    || '.' ||
    pgjwt.algorithm_sign((SELECT * FROM signables), secret, algorithm);
$$;



--
-- Name: url_decode(text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.url_decode(data text) RETURNS bytea
    LANGUAGE sql
    AS $$
WITH t AS (SELECT translate(data, '-_', '+/')),
     rem AS (SELECT length((SELECT * FROM t)) % 4) -- compute padding size
    SELECT decode(
        (SELECT * FROM t) ||
        CASE WHEN (SELECT * FROM rem) > 0
           THEN repeat('=', (4 - (SELECT * FROM rem)))
           ELSE '' END,
    'base64');
$$;



--
-- Name: url_encode(bytea); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.url_encode(data bytea) RETURNS text
    LANGUAGE sql
    AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;



--
-- Name: verify(text, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS TABLE(header json, payload json, valid boolean)
    LANGUAGE sql
    AS $$
  SELECT
    convert_from(pgjwt.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(pgjwt.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$;



--
-- Name: cookie(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.cookie(c text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.cookie.' || c);
$$;



--
-- Name: env_var(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.env_var(v text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select current_setting(v, true);
$$;



--
-- Name: header(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.header(h text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.header.' || h);
$$;



--
-- Name: jwt_claim(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.jwt_claim(c text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.jwt.claim.' || c);
$$;



--
-- Name: user_id(); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.user_id() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    select 
    case coalesce(request.jwt_claim('user_id'),'')
    when '' then 0
    else request.jwt_claim('user_id')::int
	end
$$;



--
-- Name: user_role(); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.user_role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.jwt_claim('role')::text;
$$;



--
-- Name: get(text); Type: FUNCTION; Schema: settings; Owner: superuser
--

CREATE FUNCTION settings.get(text) RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
    select value from settings.secrets where key = $1
$_$;



--
-- Name: set(text, text); Type: FUNCTION; Schema: settings; Owner: superuser
--

CREATE FUNCTION settings.set(text, text) RETURNS void
    LANGUAGE sql SECURITY DEFINER
    AS $_$
	insert into settings.secrets (key, value)
	values ($1, $2)
	on conflict (key) do update
	set value = $2;
$_$;



--
-- Name: collectionslinks; Type: VIEW; Schema: data; Owner: superuser
--

CREATE VIEW data.collectionslinks AS
 SELECT collections.id,
    collections.title,
    collections.description,
    collections.keywords,
    collections.version,
    collections.license,
    collections.providers,
    collections.extent,
    collections.properties,
    ( SELECT array_cat(ARRAY[ROW((( SELECT (((apiurls.url)::text || '/collections/'::text) || (collections.id)::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'self'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject, ROW((( SELECT (((apiurls.url)::text || '/collections/'::text) || (collections.id)::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'root'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject], collections.links) AS array_cat) AS links
   FROM data.collections;



--
-- Name: collections; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.collections AS
 SELECT collectionslinks.id,
    collectionslinks.title,
    collectionslinks.description,
    collectionslinks.keywords,
    collectionslinks.version,
    collectionslinks.license,
    collectionslinks.providers,
    collectionslinks.extent,
    collectionslinks.properties,
    collectionslinks.links
   FROM data.collectionslinks;


ALTER TABLE api.collections OWNER TO api;

--
-- Name: items_string_geometry; Type: VIEW; Schema: data; Owner: superuser
--

CREATE VIEW data.items_string_geometry AS
 SELECT itemslinks.id,
    itemslinks.type,
    (data.st_asgeojson(itemslinks.geometry))::json AS geometry,
    itemslinks.bbox,
    itemslinks.properties,
    itemslinks.assets,
    itemslinks.collection,
    itemslinks.datetime,
    itemslinks.links,
    itemslinks.stac_version
   FROM data.itemslinks;



--
-- Name: items; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.items AS
 SELECT items_string_geometry.id,
    items_string_geometry.type,
    items_string_geometry.geometry,
    items_string_geometry.bbox,
    items_string_geometry.properties,
    items_string_geometry.assets,
    items_string_geometry.collection,
    items_string_geometry.datetime,
    items_string_geometry.links,
    items_string_geometry.stac_version
   FROM data.items_string_geometry;


ALTER TABLE api.items OWNER TO api;

--
-- Name: rootlinks; Type: VIEW; Schema: data; Owner: superuser
--

CREATE VIEW data.rootlinks AS
 SELECT 'sat-api-pg'::text AS title,
    'sat-api-pg'::text AS id,
    'STAC v0.8.0 implementation by Development Seed'::text AS description,
    '0.8.0'::text AS stac_version,
    ( SELECT ARRAY[ROW((( SELECT ((apiurls.url)::text || '/collections'::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'data'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject, ROW((( SELECT ((apiurls.url)::text || '/conformance'::text)
                   FROM data.apiurls
                 LIMIT 1))::character varying(1024), 'conformance'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject, ROW(( SELECT apiurls.url
                   FROM data.apiurls
                 LIMIT 1), 'self'::character varying(1024), 'application/json'::character varying(1024), NULL::character varying(1024))::data.linkobject] AS "array") AS links;



--
-- Name: root; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.root AS
 SELECT rootlinks.title,
    rootlinks.id,
    rootlinks.description,
    rootlinks.stac_version,
    rootlinks.links
   FROM data.rootlinks;


ALTER TABLE api.root OWNER TO api;

--
-- Name: user; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data."user" (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role data.user_role DEFAULT (settings.get('auth.default-role'::text))::data.user_role NOT NULL,
    CONSTRAINT user_email_check CHECK ((email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
    CONSTRAINT user_name_check CHECK ((length(name) > 2))
);



--
-- Name: user_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.user_id_seq OWNED BY data."user".id;


--
-- Name: secrets; Type: TABLE; Schema: settings; Owner: superuser
--

CREATE TABLE settings.secrets (
    key text NOT NULL,
    value text NOT NULL
);



--
-- Name: user id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user" ALTER COLUMN id SET DEFAULT nextval('data.user_id_seq'::regclass);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: settings; Owner: superuser
--

ALTER TABLE ONLY settings.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (key);


--
-- Name: collectionslinks convert_collection_links; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER convert_collection_links INSTEAD OF INSERT ON data.collectionslinks FOR EACH ROW EXECUTE PROCEDURE data.convert_collection_links();


--
-- Name: items_string_geometry convert_geometry_tg; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER convert_geometry_tg INSTEAD OF INSERT ON data.items_string_geometry FOR EACH ROW EXECUTE PROCEDURE data.convert_values();


--
-- Name: user user_encrypt_pass_trigger; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER user_encrypt_pass_trigger BEFORE INSERT OR UPDATE ON data."user" FOR EACH ROW EXECUTE PROCEDURE auth.encrypt_pass();


--
-- Name: items fk_collection; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.items
    ADD CONSTRAINT fk_collection FOREIGN KEY (collection) REFERENCES data.collections(id);


--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA api TO anonymous;
GRANT USAGE ON SCHEMA api TO application;


--
-- Name: SCHEMA data; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA data TO anonymous;
GRANT USAGE ON SCHEMA data TO application;


--
-- Name: SCHEMA request; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA request TO PUBLIC;


--
-- Name: FUNCTION login(email text, password text); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.login(email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION api.login(email text, password text) TO anonymous;
GRANT ALL ON FUNCTION api.login(email text, password text) TO webuser;


--
-- Name: FUNCTION me(); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.me() FROM PUBLIC;
GRANT ALL ON FUNCTION api.me() TO webuser;


--
-- Name: FUNCTION refresh_token(); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.refresh_token() FROM PUBLIC;
GRANT ALL ON FUNCTION api.refresh_token() TO webuser;


--
-- Name: TABLE collections; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,UPDATE ON TABLE data.collections TO api;
GRANT SELECT,INSERT,UPDATE ON TABLE data.collections TO application;


--
-- Name: TABLE items; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT ON TABLE data.items TO api;
GRANT SELECT ON TABLE data.items TO anonymous;
GRANT SELECT,INSERT,UPDATE ON TABLE data.items TO application;


--
-- Name: TABLE itemslinks; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,UPDATE ON TABLE data.itemslinks TO api;
GRANT SELECT,INSERT,UPDATE ON TABLE data.itemslinks TO application;


--
-- Name: TABLE collectionitems; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT ON TABLE api.collectionitems TO anonymous;


--
-- Name: FUNCTION signup(name text, email text, password text); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.signup(name text, email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION api.signup(name text, email text, password text) TO anonymous;


--
-- Name: TABLE collectionslinks; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,UPDATE ON TABLE data.collectionslinks TO api;
GRANT SELECT,INSERT,UPDATE ON TABLE data.collectionslinks TO application;


--
-- Name: TABLE collections; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT ON TABLE api.collections TO anonymous;
GRANT SELECT,INSERT,UPDATE ON TABLE api.collections TO application;


--
-- Name: TABLE items_string_geometry; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,UPDATE ON TABLE data.items_string_geometry TO api;
GRANT SELECT,INSERT,UPDATE ON TABLE data.items_string_geometry TO application;


--
-- Name: TABLE items; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT ON TABLE api.items TO anonymous;
GRANT SELECT,INSERT,UPDATE ON TABLE api.items TO application;


--
-- Name: TABLE rootlinks; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT ON TABLE data.rootlinks TO api;


--
-- Name: TABLE root; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT ON TABLE api.root TO anonymous;


--
-- PostgreSQL database dump complete
--

