#!/bin/bash

echo "About to retrieve Bibitem from:" $1
# https://arxiv.org/abs/1502.04623

function checkURL {
    TWOH=$(curl -s --head $1 | head -n 1 | grep 200)
    # curl -s --head https://arxiv.org/abs/khjfah | head -n 1 | grep 200
    if [[ -z $TWOH ]]; then
        echo "URL not valid"
        exit 0
    fi
}

if [[ ! $1 = *"arxiv.org/abs/"* ]]; then
  echo "This script needs a URL from arxiv like: arxiv.org/abs/*.*"
  exit 0
fi

checkURL $1

STR=$1
set -f                      # avoid globbing (expansion of *).
ARR=(${STR//\// })
REF=${ARR[${#ARR[@]}-1]}
FULLREF="http://adsabs.harvard.edu/cgi-bin/bib_query?data_type=BIBTEX&arXiv:$REF"

HTMLBIB=$(curl -s $FULLREF | tail -n +5)
NAME=$(echo $HTMLBIB | perl -ne 'print "$1\n" if /title = "{([\w*|\W*]*)}"/' | sed s/:/-/)
echo $NAME
echo $HTMLBIB >> "$NAME.bib"

# BIBNAME=$(echo $HTMLBIB | cut -d "{" -f2 | cut -d "}" -f1 | sed 's/:/-/')
# echo $BIBNAME



# # http://adsabs.harvard.edu/cgi-bin/bib_query?arXiv:1502.04623
#
# BIBCODE="name=\"bibcode\" value="
# TOREPL="value=\""
# HTMLBIB=$(curl -s $FULLREF | grep "$BIBCODE" | head -1)
# REST=${HTMLBIB#*$TOREPL}
# BIBREF=$(echo $REST | sed 's/\">//')
# echo $BIBREF
#
# # http://adsabs.harvard.edu/cgi-bin/nph-bib_query?data_type=BIBTEX&bibcode=2015arXiv150204623G
#
# SABSURL="http://adsabs.harvard.edu/cgi-bin/nph-bib_query?data_type=BIBTEX&bibcode=$BIBREF"
#
# HTMLBIB=$(curl -s $SABSURL)
# echo $HTMLBIB
# BIBNAME=$(echo $HTMLBIB | cut -d "{" -f2 | cut -d "}" -f1 | sed 's/:/-/')
# echo $BIBNAME