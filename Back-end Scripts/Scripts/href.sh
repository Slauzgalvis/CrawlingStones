#!/bin/bash
href_hash='href="#"'

Dir=`sed -n "1p" downloaded_page.txt`
if cd pages/$Dir ; then
find -name "*.html" > find_file.txt
html=`grep -c "^" find_file.txt`

for (( j=1; j <= $html; ++j ))
do
	html_file=`sed "${j}!d" find_file.txt`
	sed -i 's,href="http://,href=",g' "$html_file"
	sed -i 's,href="https://,href=",g' "$html_file"
	grep -o 'href="www[^ ]*' "$html_file" | egrep -o '^[^>]+' >> href.txt
	hrefs=`grep -c "^" href.txt`
	for (( q=1; q <= $hrefs; ++q ))
	do
		href_change=`sed "${q}!d" href.txt`
		sed -i "s,$href_change,$href_hash,g" "$html_file"
	done
	rm -rf href.txt	
done

rm -rf find_file.txt
cd ../..
fi
