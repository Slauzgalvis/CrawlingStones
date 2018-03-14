#!/bin/bash
DB_USR="root"
DB_PSW="root1234"
DB_NAME="WebArchive"

DEFAULT_RESTRICTION_LIST='"-*calendar*" "-*.pdf" "-*.docx" "-*.tar" "-*.zip" "-*.img" "-*.iso" "-*.doc" "-*.gif"'

mysql -u$DB_USR -p$DB_PSW -D $DB_NAME -se"select page_url from Url_list;" > list.txt
domains=`grep -c "^" list.txt`

for (( i=1; i <= $domains; ++i ))
do      
        Dir=`sed -n "${i}p" list.txt`
        DATE_START=`date "+%Y-%m-%d %H:%M:%S"`
	echo "------------------------------------------------------------" >> result.txt
        echo "$Dir START: $DATE_START" >> result.txt
	echo "------------------------------------------------------------" >> result.txt
        cd pages
        restrictions=$(mysql -u$DB_USR -p$DB_PSW -D $DB_NAME -se"select extension_list from RejectList where page_url = '$Dir';")
        if [[ ! "$restrictions" ]]; then
                restrictions=$DEFAULT_RESTRICTION_LIST
        fi
        httrack $Dir/ -w -%P --robots=0 -B $restrictions --disable-security-limits --retries=1 --verbose -C0 -I0 --display -z --max-rate=99999 -#f
        cd ..
        DATE_END=`date "+%Y-%m-%d %H:%M:%S"`
        echo "$Dir END: $DATE_END" >> result.txt
	echo "------------------------------------------------------------" >> result.txt
        echo "Downloaded $Dir in $(( ( $(date -ud "$DATE_END" +'%s') - $(date -ud "$DATE_START" +'%s') )/60 )) minutes" >> result.txt
	echo "------------------------------------------------------------" >> result.txt
        echo $Dir > downloaded_page.txt
        ./Scripts/mount.sh #
        ./Scripts/href.sh #     
        ./Scripts/newbtrfs.sh #
        ./Scripts/check.sh #
	rm downloaded_page.txt
	rm -rf pages/$Dir
done

rm list.txt