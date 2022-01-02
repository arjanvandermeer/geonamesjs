#!/bin/bash
#
# Based on getgeo.sh:
# AUTHOR: Andreas (aka Harpagophyt )
# COMPANY: <a href="http://forum.geonames.org/gforum/posts/list/926.page" target="_blank" rel="nofollow">http://forum.geonames.org/gforum/posts/list/926.page</a>
# VERSION: 1.5 - 2012-10-01

# To fix - should use docker environment variables

WORKPATH="/tmp/geonames.work"
TMPPATH="tmp"
PCPATH="pc"
PREFIX="_"
DBHOST="localhost"
DBPORT="5432"
DBUSER="postgres"
DATABASE="postgres"
SCHEMA="postgis"
FILES="allCountries.zip alternateNames.zip userTags.zip admin1CodesASCII.txt admin2Codes.txt countryInfo.txt featureCodes_en.txt iso-languagecodes.txt timeZones.txt"

export PGOPTIONS="--search_path=${SCHEMA}"

# check if needed directories do already exsist
if [ -d "$WORKPATH" ]; then
    echo "$WORKPATH exists..."
    sleep 0
else
    echo "$WORKPATH and subdirectories will be created..."
    mkdir -p $WORKPATH/{$TMPPATH,$PCPATH}
    echo "created $WORKPATH"
fi

echo
echo ",---- STARTING (downloading, unpacking and preparing)"
cd $WORKPATH/$TMPPATH
for i in $FILES
do
    wget -N -q "http://download.geonames.org/export/dump/$i" # get newer files
    if [ $i -nt $PREFIX$i ] || [ ! -e $PREFIX$i ] ; then
        cp -p $i $PREFIX$i
        if [[ $i == *.zip ]]
        then
          unzip -u -q $i
        fi
        
        case "$i" in
            iso-languagecodes.txt)
                tail -n +2 iso-languagecodes.txt > iso-languagecodes.txt.tmp;
                ;;
            countryInfo.txt)
                grep -v '^#' countryInfo.txt > countryInfo.txt.tmp;
                ;;
            timeZones.txt)
                tail -n +2 timeZones.txt > timeZones.txt.tmp;
                ;;
        esac
        echo "| $i has been downloaded";
    else
        echo "| $i is already the latest version"
    fi
done

# -h $DBHOST -p $DBPORT
psql -e -U $DBUSER  $DATABASE << EOF
set schema 'postgis';
\copy geoname (id,name,ascii_name,alternate_names,latitude,\
              longitude,fclass,fcode,country,cc2,admin1,admin2,\
              admin3,admin4,population,elevation,gtopo30,\
              timezone,modified_date)\
    from '${WORKPATH}/${TMPPATH}/allCountries.txt' null as '';
\copy timeZones (country_code,id,GMT_offset,DST_offset,raw_offset)\
    from '${WORKPATH}/${TMPPATH}/timeZones.txt.tmp' null as '';
\copy featureCodes (code,name,description)\
    from '${WORKPATH}/${TMPPATH}/featureCodes_en.txt' null as '';
\copy admin1CodesAscii (code,name,name_ascii,geoname_id)\
    from '${WORKPATH}/${TMPPATH}/admin1CodesASCII.txt' null as '';
\copy admin2CodesAscii (code,name,name_ascii,geoname_id)\
    from '${WORKPATH}/${TMPPATH}/admin2Codes.txt' null as '';
\copy iso_languagecodes (iso_639_3,iso_639_2,iso_639_1,language_name)\
    from '${WORKPATH}/${TMPPATH}/iso-languagecodes.txt.tmp' null as '';
\copy countryInfo (iso_alpha2,iso_alpha3,iso_numeric,fips_code,country,\
                  capital,area,population,continent,tld,currency_code,\
                  currency_name,phone,postal,postal_regex,languages,\
                  geoname_id,neighbours,equivalent_fips_code)\
    from '${WORKPATH}/${TMPPATH}/countryInfo.txt.tmp' null as '';
\copy alternatename (id,geoname_id,iso_lang,alternate_name,\
                    is_preferred_name,is_short_name,\
                    is_colloquial,is_historic)\
    from '${WORKPATH}/${TMPPATH}/alternateNames.txt' null as '';
EOF