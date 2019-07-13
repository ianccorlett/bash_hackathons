#! bin/bash

#infile=$1

read -p "select the Skylight file: " -i "./" -e infile
echo "you chose: " $infile


#echo "would you like to normalise input company names?[y/n]"
#read normalise
#echo $normalise

cat -n $infile | head -n50 

echo "which skylight company line would you like to alias match?"

read num

echo "you selected: " 
yourco=$(cat $infile | head -n$num | tail -n1)
echo $yourco

######## FIND ALIASES #############

echo "finding aliases -->  canonical names --> sorted by frequency"

cat $infile | head -n$num  | tail -n1 | bash getSkylightAliases.sh > xx.tmp

echo "these are the best matching canonical aliases:"
cat xx.tmp

cat xx.tmp | sed 's/^[^"]*"/"/'  > out.tmp

echo "output stored in out.tmp"

awk '{print "," $0}' out.tmp | tr -d '"' > out.forexatmatch.tmp

echo "output for exactmatch stored in out.forexactmatch.tmp"

loweryourco=$(echo $yourco | bash tolower.sh)


########## DOMAINS BY ALIAS ###########

echo "would you like to find additional aliases by domain?[y/n]"

read domainResponse

case $domainResponse
in
y)

domain=$(cat $infile | head -n$num  | tail -n1 )
#echo $domain

moredomains=$(bash 2-1_get-company-domain.sh $domain)

#echo $moredomains | jq .


moredomainssimple=$(echo $moredomains | jq -c . | bash tolower.sh | grep "$loweryourco" | jq -c '.domain' )

#echo "the best matching domains are: " $moredomainssimple 

topdomain=$( echo $moredomainssimple | jq . | head -n1 | tr -d '"')

echo "the very best matching domains is: " 
echo "X"$topdomain"X"

domainCompanies=$(bash get_companies_by_domain.sh "$topdomain")
echo "domain companies are:" $domainCompanies
;;
esac

echo " "
echo " "
echo " "

#sleep 1s 


echo "the final list of company aliases is...."
echo " "
#sleep 2s

echo "using alias and canonical"
echo " "
cat xx.tmp

case $domainResponse
in
y)
#sleep 2s
echo "using domain, alias and canonical"
echo " "
echo $domainCompanies | jq -c '.[][0]'
;;
esac

cat out.tmp > alias.tmp
case $domainResponse
in
y)
echo $domainCompanies | jq -c '.[][0]' >> alias.tmp
;;esac

echo  "$loweryourco" >> alias.tmp
printf '\n\n\n'
echo "aliases saved to alias.tmp"

cat alias.tmp

######### IDENTIFY AND MAP ALIASES ###################

echo "would you like to find these aliases in tjg file? [y/n]"
read findResponse

#cat alias.tmp | sed -e "s/'/\'/g" | xargs -I {} bash getcaseoptions-args.sh -r "true" -c {} | xargs -I{} bash grepCoOptions.sh {} > grepaliases.tmp
#cat alias.tmp | sed -e "s/'/\'/g" | xargs -I{} bash grepCoOptions.sh {} > grepaliases.tmp
cat alias.tmp | sed -e "s/'/\'/g" -e 's/"//g' | awk '{ print "\""$0"\""}' | xargs -I{} bash grepCoOptions-args.sh -n "true" -c {} > grepaliases.tmp

echo "these matches were found in tjg file...."
cat grepaliases.tmp
#cat grepaliases.tmp | awk -F "," '{print $2}'

echo "would you like to map the ids?"
read mapidsResponse

echo "skyco is " $loweryourco
echo "tjgco is " 
cat grepaliases.tmp | awk -F "," '{print $1}'

cat grepaliases.tmp  | awk -F "," '{print $1}' | xargs -I {} bash ZZ-0-mapSkylightIDs2TjgIDs.sh "$loweryourco" {} 



echo "would you like to find canonical references for these companies? [y/n]"
read canonResponse
case $canonResponse
in
y)
echo "here are canonical names for the above aliases"
#finalCanon=$(cat alias.tmp | xargs -I {} bash get_canonical_name.sh {} | jq '.data[][]' | bash tolower.sh | sort | uniq -c | sort -nr)
#finalCanon=$(cat alias.tmp | xargs -I {} bash get_canonical_name.sh {} | jq '.data[][]' | bash tolower.sh | sort | uniq -c | sort -nr | awk '{print "["$0"],"}')
finalCanon=$(cat alias.tmp | xargs -I {} bash get_canonical_name.sh {} )

echo $finalCanon | jq '.data[][]' | bash tolower.sh | sort | uniq -c | sort -nr
#echo $finalCanon | awk '{print "["$0"]"}' 

echo $finalCanon > canonical.tmp

echo "canonical names saved to canonical.tmp"
;; esac



printf "\n\n"
echo "good bye"

