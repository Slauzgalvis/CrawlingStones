#!/bin/bash
DATE_START=`date "+%Y-%m-%d %H:%M:%S"`
echo >> result.txt
echo "####################### SYSTEM STARTS #######################" >> result.txt
echo >> result.txt
./Scripts/crawling.sh
echo >> result.txt
echo "*********************** CRAWLING END ***********************" >> result.txt
echo >> result.txt
echo >> result.txt
DATE_END=`date "+%Y-%m-%d %H:%M:%S"`
echo "#################### END OF THE SYSTEM  #####################" >> result.txt
echo "SYSTEM START: $DATE_START" >> result.txt 
echo "SYSTEM END: $DATE_END" >> result.txt
echo "System lasted: $(( ( $(date -ud "$DATE_END" +'%s') - $(date -ud "$DATE_START" +'%s') )/60 )) minutes" >> result.txt
echo "#############################################################" >> result.txt
mv result.txt result/"$DATE_END".txt
cat error.txt >> result.txt
