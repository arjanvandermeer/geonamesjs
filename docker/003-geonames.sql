set schema 'postgis';

INSERT INTO continentCodes VALUES ('AF', 'Africa', 6255146);
INSERT INTO continentCodes VALUES ('AS', 'Asia', 6255147);
INSERT INTO continentCodes VALUES ('EU', 'Europe', 6255148);
INSERT INTO continentCodes VALUES ('NA', 'North America', 6255149);
INSERT INTO continentCodes VALUES ('OC', 'Oceania', 6255150);
INSERT INTO continentCodes VALUES ('SA', 'South America', 6255151);
INSERT INTO continentCodes VALUES ('AN', 'Antarctica', 6255152);
CREATE INDEX concurrently index_countryinfo_geonameid ON countryinfo (geoname_id);
CREATE INDEX concurrently index_alternatename_geonameid ON alternatename (geoname_id);

alter table only featureCodes add constraint pk_featurecodescode primary key (code);
alter table only timezones add constraint pk_timezonesid primary key (id);
alter table only postalcodes add constraint pk_country_code_postal_code primary key (country_code, postal_code);
alter table only iso_languagecodes add constraint pk_iso_639_3 primary key (iso_639_3);
alter table only continentcodes add constraint pk_continentcodescode primary key (code);
alter table only admin2codesascii add constraint pk_admin2codesasciicode primary key (code);
alter table only admin1codesascii add constraint pk_admin1codesasciicode primary key (code);
----CREATE INDEX geoname_name_ftindex ON postgis.geoname USING gin(name);
CREATE INDEX concurrently geoname_name_ftindex_gist_name ON geoname USING gist(name gist_trgm_ops);
CREATE INDEX concurrently geoname_name_ftindex_gist_ascii_name ON geoname USING gist(ascii_name gist_trgm_ops);


ALTER TABLE ONLY alternatename
    ADD CONSTRAINT pk_alternatenameid PRIMARY KEY (id);
ALTER TABLE ONLY geoname
    ADD CONSTRAINT pk_geonameid PRIMARY KEY (id);
ALTER TABLE ONLY countryinfo
    ADD CONSTRAINT pk_iso_alpha2 PRIMARY KEY (iso_alpha2);
ALTER TABLE ONLY countryinfo
    ADD CONSTRAINT fk_geonameid FOREIGN KEY (geoname_id)
        REFERENCES geoname(id);
ALTER TABLE ONLY alternatename
    ADD CONSTRAINT fk_geonameid FOREIGN KEY (geoname_id)
        REFERENCES geoname(id);

alter table geoname
	add search_vector tsvector;

update geoname
set search_vector = to_tsvector('english', concat_ws(' ', name, ascii_name, alternate_names)) 
where true;

create index concurrently geoname_search_vector_idx
    on geoname using gin (search_vector);

----CREATE INDEX concurrently trgm_idx ON geoname USING gin (ascii_name extensions.gin_trgm_ops);