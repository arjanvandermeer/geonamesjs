FROM postgres

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get update && apt-get install -y wget unzip postgresql-contrib

EXPOSE 5432

COPY ["./001-geonames.sql","/docker-entrypoint-initdb.d/001-geonames.sql"]
COPY ["./002-geonames.sh","/docker-entrypoint-initdb.d/002-geonames.sh"]
COPY ["./003-geonames.sql","/docker-entrypoint-initdb.d/003-geonames.sql"]
COPY ["./004-geonames.sh","/docker-entrypoint-initdb.d/004-geonames.sh"]

ENV POSTGRES_PASSWORD "geonames"

CMD ["postgres"]