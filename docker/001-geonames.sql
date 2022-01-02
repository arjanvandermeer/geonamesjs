Create schema postgis;
set schema 'postgis';

        DROP TABLE IF EXISTS geoname CASCADE;
        DROP TABLE IF EXISTS alternatename;
        DROP TABLE IF EXISTS countryinfo;
        DROP TABLE IF EXISTS iso_languagecodes;
        DROP TABLE IF EXISTS admin1CodesAscii;
        DROP TABLE IF EXISTS admin2CodesAscii;
        DROP TABLE IF EXISTS featureCodes;
        DROP TABLE IF EXISTS timeZones;
        DROP TABLE IF EXISTS continentCodes;
        DROP TABLE IF EXISTS postalcodes;

    CREATE TABLE geoname (
        id              INT,
        name            TEXT,
        ascii_name      TEXT,
        alternate_names TEXT,
        latitude        FLOAT,
        longitude       FLOAT,
        fclass          CHAR(1),
        fcode           CHAR(10),
        country         CHAR(2),
        cc2             TEXT,
        admin1          TEXT,
        admin2          TEXT,
        admin3          TEXT,
        admin4          TEXT,
        population      BIGINT,
        elevation       INT,
        gtopo30         INT,
        timezone        TEXT,
        modified_date   DATE
    );
    CREATE TABLE alternatename (
        id                INT,
        geoname_id        INT,
        iso_lang          TEXT,
        alternate_name    TEXT,
        is_preferred_name BOOLEAN,
        is_short_name     BOOLEAN,
        is_colloquial     BOOLEAN,
        is_historic       BOOLEAN
    );
    CREATE TABLE countryinfo (
        iso_alpha2           CHAR(2),
        iso_alpha3           CHAR(3),
        iso_numeric          INTEGER,
        fips_code            TEXT,
        country              TEXT,
        capital              TEXT,
        area                 DOUBLE PRECISION, -- square km
        population           INTEGER,
        continent            CHAR(2),
        tld                  TEXT,
        currency_code        CHAR(3),
        currency_name        TEXT,
        phone                TEXT,
        postal               TEXT,
        postal_regex         TEXT,
        languages            TEXT,
        geoname_id           INT,
        neighbours           TEXT,
        equivalent_fips_code TEXT
    );
    CREATE TABLE iso_languagecodes(
        iso_639_3     CHAR(4),
        iso_639_2     TEXT,
        iso_639_1     TEXT,
        language_name TEXT
    );
    CREATE TABLE admin1CodesAscii (
        code       CHAR(20),
        name       TEXT,
        name_ascii  TEXT,
        geoname_id INT
    );
    CREATE TABLE admin2CodesAscii (
        code      CHAR(80),
        name      TEXT,
        name_ascii TEXT,
        geoname_id INT
    );
    CREATE TABLE featureCodes (
        code        CHAR(7),
        name        TEXT,
        description TEXT
    );
    CREATE TABLE timeZones (
        id           TEXT,
        country_code TEXT,
        GMT_offset NUMERIC(3,1),
        DST_offset NUMERIC(3,1),
        raw_offset NUMERIC(3,1)
    );
    CREATE TABLE continentCodes (
        code       CHAR(2),
        name       TEXT,
        geoname_id INT
    );
    CREATE TABLE postalcodes (
        country_code CHAR(2),
        postal_code  TEXT,
        place_name   TEXT,
        admin1_name  TEXT,
        admin1_code  TEXT,
        admin2_name  TEXT,
        admin2_code  TEXT,
        admin3_name  TEXT,
        admin3_code  TEXT,
        latitude     FLOAT,
        longitude    FLOAT,
        accuracy     SMALLINT
    );
    CREATE EXTENSION pg_trgm;
    CREATE EXTENSION btree_gin;