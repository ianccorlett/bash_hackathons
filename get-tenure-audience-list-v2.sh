#!/usr/local/bin/bash

#config
PERSON_API=trufa_url
CAREERPATH_API=graph_url

urlencode() {
  python -c 'import urllib, sys; print urllib.quote(sys.argv[1], sys.argv[2])' \
    "$1" "$urlencode_safe"
}
#inputs are :
#industry
#network
industry=$1
network=$2
#### clear tmp files
> roles.tmp
> persons.tmp
####for each industry and network get related roles
echo "#######get roles#########"
curlQry=$(curl -X GET --header 'Accept: application/json' --header 'Authorization: id=dolphinteam, apiKey=[your key]'  $PERSON_API'/api/v3/graph/person?facet=role&industry='$industry'&count=100')
echo $curlQry | jq '.results.role[].name' > roles.tmp
cat roles.tmp 
####for each facet role in the industry
cat roles.tmp | while read line; do
#####find the average role tenure
   printf "\n\n"
   echo "#########get average tenure#########"
   lineRole=$(echo $line | tr -d '"' )
   normalisedRole=$( urlencode "$lineRole")
   echo $normalisedRole
 
   tenureQry=$(curl -X GET --header 'Accept: application/json' $CAREERPATH_API'/_db/careerPath/career/role?name='$normalisedRole'&maxNodes=10&sortBy=frequency')
   tenure=$(echo $tenureQry | jq '.response[].tenure')
   echo "average tenure is " $tenure
  
####search for people by: 
####role  = facet role
####role start date = this month minus average role tenure
####role end date = now/future
   printf "\n\n"
   echo "#########find people############"
   tenureS=$(($tenure+1))
   tenureE=$(($tenure-1))
#   echo "tenureS" $tenureS
   startDateFrom=$(date --date $tenureS" months ago" +%Y-%m-01)
   startDateTo=$(date --date $tenureE" months ago" +%Y-%m-01)
   endDateFrom=$(date --date "today" +%Y-%m-%d)
   echo "startDateFrom XX"$startDateFrom"XX"
   echo "startDateTo XX"$startDateTo"XX"
   echo "endDateFrom XX"$endDateFrom"XX"
   personQry=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'Authorization: id=dolphinteam, apiKey=[your key here]' \
   -d '{    "start": 0, "count": 100,"query": { "AND": [  {  "entity": "experience", "criteria": { "start": { "from": "'"$startDateFrom"'", "to": "'"$startDateTo"'" },  "end": { "from": "'"$endDateFrom"'" }, "role": "accountant" } }, { "entity": "country_code", "criteria": { "value": "GB" } }, { "entity": "network", "criteria": { "name": "'"$network"'" } } ] }}'\
    $PERSON_API'/api/v5/person'   )
   echo $personQry > persons.tmp
#   cat persons.tmp | jq -c '.results[]' | head -n1
###return:
#####email address
#####headline
##### perhaps??:
#####start date
#####end date
#####company
#####network
#####id
#####industry
   cat persons.tmp | jq -c '.results[].synopsis | {"fullName": .fullName, "emailAddress1": .emailAddresses[0], "emailAddress2": .emailAddresses[1], "headline": .headline}' >> results.tmp
   tail results.tmp
done
