getCo=$1

#CONFIG
NEO4J_API=[neo_url]

curl \
   -H "Accept: application/json; charset=UTF-8" \
   -H "Content-Type: application/json" \
   -X POST \
   --user [user]:[password] \
   "$NEO4J_API"/db/data/cypher \
   -d '{"query": " MATCH p=(a:Company)-[:subOrganization|dbpediaRedirects|acquired|aliases|dbpediaDivision|dbpediaName|opencalaisAlias|stepwebModifiedForm*1..5]-(b:Company) WHERE a.name = {coname}         RETURN distinct b.name as names UNION MATCH p=(a:Company)-[:subOrganization|dbpediaRedirects|acquired|aliases|dbpediaDivision|dbpediaName|opencalaisAlias|stepwebModifiedForm*1..5]-(b:Company)-[:hoppenstedtAlias|bhoppenstedtFormerName|swanLinkedin|stepwebStrippedForm|dupstep|dbpediaOwner]-(c:Company) WHERE a.name = {coname} return distinct c.name as names UNION MATCH p=(a:Company)-[:hoppenstedtAlias|bhoppenstedtFormerName|swanLinkedin|stepwebStrippedForm|dupstep|dbpediaOwner]-(c:Company) WHERE a.name = {coname} return distinct c.name as names", "params": {"coname": "'"$getCo"'"} }'   | jq '.data[] | .[]'

