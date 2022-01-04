#!/bin/bash
#
DNSERROR="No DNS address"
FULL_PATH_TO_SCRIPT="$(realpath "$0")"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"

if [ ! -f "$SCRIPT_DIRECTORY/.ENV" ]; then
    echo "$SCRIPT_DIRECTORY/.ENV does not exist."
    echo "ENV.example is template to use"
    exit 1
fi
source "$SCRIPT_DIRECTORY"/.ENV

PID=$$
mkdir -p "$DIR"
LISTSEC="$DIR/seclist.${PID}.log"
DATESEC="$DIR/secdates.${PID}.log"
ISSUESEC="$DIR/secissues.${PID}.log"
DNSISSUESEC="$DIR/dnsissues.${PID}.log"
CERTISSUESEC="$DIR/certissues.${PID}.log"

#
# Get the services
docker service ls |grep 1/1 |grep second| awk '{ print $2 $6} ' | sed 's/_secondary\*/.hornet.atsign.zone/g' |sed 's/->.*$//g' > $LISTSEC
#Cylce through the services
# Check DNS entry
# Check Expiry Date within X days
echo -n > $DATESEC
for secondary in `cat $LISTSEC`
do
        echo -n  ${secondary}: >> $DATESEC
        nslookup  ${secondary//:*/} &>/dev/null
        if [[ $? -eq 0 ]]
         then
                 echo | openssl s_client -connect $secondary 2>/dev/null | openssl x509 -noout  -checkend $EXPIREDAYS >> $DATESEC
         else
                echo $DNSERROR >> $DATESEC
        fi
 done

# Check results
grep -v "Certificate will not expire" $DATESEC > $ISSUESEC
TOTALPROBLEMS=$(cat ./issues | wc -l)
DNSPROBLEMSCOUNT="$(grep "$DNSERROR" ./issues| wc -l)"
CERTPROBLEMSCOUNT=$((TOTALPROBLEMS - DNSPROBLEMSCOUNT))

grep "$DNSERROR"  $ISSUESEC| tail -$MAX  > $DNSISSUESEC
grep -v "$DNSERROR"  $ISSUESEC| tail -$MAX > $CERTISSUESEC


 while IFS= read -r line
 do
 CERTISSUES="${CERTISSUES}"$'\n'"${line}"
 done < $CERTISSUESEC

 while IFS= read -r line
 do
 DNSISSUES="${DNSISSUES}"$'\n'"${line}"
 done < $DNSISSUESEC

if [[ $TOTALPROBLEMS -gt 0 ]]
then
curl --location --request POST "${URL}" --header 'Content-Type: application/json' --data-raw "{\"text\": \"Total number of secondaries with certificate or DNS problems ${TOTALPROBLEMS}\n\n${CERTPROBLEMSCOUNT} S
econdary Certificates that expire in less than $EXPIREDAYS days\n${DNSPROBLEMSCOUNT} Problematic Secondary DNS entries\n\nFirst up to ${MAX} secondaries with issues with certificates ${CERISSUES} \n\nFirst up t
o ${MAX} secondaries with DNS issues ${DNSISSUES}\"}"
fi