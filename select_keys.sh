#/bin/bash



sed  '/[/]items/q'  zbx_template.xml |  grep -o -P '(?<=[<]key[>]).*(?=[</]key[>])' | tr -d "<" | sort -u > kys_temp
 
sed  '/[/]items/q'  absible_template.xml  |  grep -o -P '(?<=[<]key[>]).*(?=[</]key[>])' | tr -d "<" | sort -u >> kys_temp





while read line; do


# Select Items created in one line in query_fe.props
service_code=$(grep -w -i $line  query_fe.props  | grep -v QueryList | grep -o -P '(?<=service_id=).*(?=and)')


if [[ -z  $service_code   ]]; then
# Select Items created in more than line in query_fe.props

  service_code=$(grep  -w -i  $line.Query  query_fe.props| tr -d " " |tr -d ")"  |grep   -v QueryList|sort -u | grep -oP "(?<=addldata=)[^ ]+")

# Select Balance Items Items created in query_fe.props

  if [[ -z $service_code  ]]; then
        service_code=$(grep -A3  -w -i  $line  query_fe.props| tr -d "'" | grep -v QueryList | grep -oP "(?<=acct1=)[^ ]+" | sort -u)


# Select Items created in more line in query_fe.props
       if [[ -z $service_code  ]]; then
       service_code=$(grep  -w -A7  -i $line.Query  query_fe.props| tr -d " " |tr -d ")"  |grep   -v QueryList|sort -u | grep -oP "(?<=addldata=)[^ ]+")

      fi
   fi
fi

#select names of kys from temp
if [[ -n $line ]] ;then

name=$(sed  '/[/]items/q'  zbx_template.xml | grep -B4 -w "$line"  |  grep -o -P '(?<=[<]name[>]).*(?=[</]name[>])' | tr -d "<")
if [[ -n $name ]] ;then

sed -i "s/<name>$name/<name>$name $service_code/g" zbx_template.xml   2> /dev/null
else


name=$(sed  '/[/]items/q'  absible_template.xml | grep -B4 -w "$line"  |  grep -o -P '(?<=[<]name[>]).*(?=[</]name[>])' | tr -d "<")


sed -i  "s/<name>$name/<name>$name $service_code/g" absible_template.xml 2> /dev/null


fi
 fi

echo "$name" "$service_code"  >>  kys_service



done < kys_temp

