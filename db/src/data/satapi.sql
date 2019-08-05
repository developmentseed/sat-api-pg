CREATE EXTENSION postgis SCHEMA data;
CREATE EXTENSION ltree SCHEMA data;
CREATE TABLE collections(
  collection_id serial PRIMARY KEY,
  id varchar(1024),
  description varchar(1024),
  name varchar(20),
  properties jsonb
);
CREATE TABLE items(
  item_id serial PRIMARY KEY,
  id varchar(1024),
  type varchar(20),
  geometry geometry,
  properties jsonb,
  collection_id integer NOT NULL,
  CONSTRAINT fk_collection FOREIGN KEY (collection_id) REFERENCES collections(collection_id)
);
CREATE TABLE assets(
  asset_id serial PRIMARY KEY,
  href varchar(1024),
  title varchar(1024),
  type varchar(256),
  item_id integer NOT NULL,
  CONSTRAINT fk_item FOREIGN KEY (item_id) REFERENCES items(item_id)
);

