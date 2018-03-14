#!/bin/bash
DB_USR="root"
DB_PSW="root1234"
DB_NAME="WebArchive"
#Config
####################################
percentage_limit=`mysql -u$DB_USR -p$DB_PSW -D $DB_NAME -se"select percentage_limit from Config;"`
line_limit=`mysql -u$DB_USR -p$DB_PSW -D $DB_NAME -se"select line_limit from Config;"`
####################################



Snap=_Snapshot
homepath=`pwd`
Dir=`sed -n "1p" downloaded_page.txt`
Arch=/mnt/$Dir/
change_found_check=0
DATE=`date +%Y-%m-%d:%H:%M:%S`


if cd pages/$Dir ; then
	touch $homepath/$Dir.txt
	if touch $homepath/db/$Dir/$DATE.txt; then
		:
	else
		mkdir $homepath/db/$Dir
		touch $homepath/db/$Dir/$DATE.txt	
	fi

	find \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.jpg" \) > find_file.txt
	html=`grep -c "^" find_file.txt`

	for (( j=1; j <= $html; ++j ))
	do
		new_file_check=0
		html_file=`sed "${j}!d" find_file.txt`
		x=`md5sum "$html_file"`
		y=`md5sum $Arch"$html_file"`

		if [ -z "${y}" ]; then
			y="new $Arch$html_file"
			echo "new file was found"
			newpath=${html_file%/*} 
			sudo mkdir -p $Arch"$newpath"
			new_file_check=1
		fi

		x1=`echo "$x" | awk '{print $1;}'` #md5
		x2=`echo "$x" | cut -f 1 -d ' ' --complement | sed 's/^ *//'` #path
		y1=`echo "$y" | awk '{print $1;}'` #md5
		y2=`echo "$y" | cut -f 1 -d ' ' --complement | sed 's/^ *//'` #path

		if [[ $x1 == $y1 ]]; then 
			echo "same" >> $homepath/$Dir.txt
			#same css jss
		else
			if [[ $new_file_check > 0 ]]; then
				if [[ -z "$(echo $x2 | grep '\.css\|\.js')" ]]; then
					sudo cp -f "$x2" "$y2"
					echo "$x2 **NEW ONE**" >> $homepath/db/$Dir/$DATE.txt
					echo "new" >> $homepath/$Dir.txt
				else
					sudo cp -f "$x2" "$y2"
					echo "$x2 **NEW ONE**" >> $homepath/db/$Dir/$DATE.txt
					echo "n cssorjs" >> $homepath/$Dir.txt
					change_found_check=$change_found_check+1
				fi
			else
				if [[ -n "$(echo $x2 | grep '\.css\|\.js')" ]]; then
					sudo cp -f "$x2" "$y2"
					echo "$x2 js or css changed" >> $homepath/db/$Dir/$DATE.txt
					echo "c cssorjs" >> $homepath/$Dir.txt
					change_found_check=$change_found_check+1
				else
					if [[ -n "$(echo $x2 | grep '\.jpg')" ]];then
						sudo cp -f "$x2" "$y2"
					else
						insert=`wdiff -s "$y2" "$x2" | tail -1` # gali buti 0 words
						insert=${insert#*:}
						zero_words=`echo $insert | awk '{print $1;}' | sed 's/\%//g'`

						if [[ -n ${zero_words//[0-9]/} ]]; then
							echo "$x2" >> $homepath/error.txt
						else

							if [ "$zero_words" == "0" ];then
								echo "$x2" >> $homepath/error.txt
							else
								changed=`echo $insert | awk '{print $10;}' | sed 's/\%//g'`
								insert=`echo $insert | awk '{print $7;}' | sed 's/\%//g'`

								if `diff=$(($insert+$changed))` ; then
									diff=$(($insert+$changed))
									lines=`diff -u "$y2" "$x2" | grep "^+" | wc -l`
									if [[ $diff -gt $percentage_limit ]]; then
										if [[ $lines -gt $line_limit ]]; then
											echo "changed" >> $homepath/$Dir.txt
											sudo cp -f "$x2" "$y2"
											echo "$x2 changed %: $diff % lines changed: $lines"  >> $homepath/db/$Dir/$DATE.txt
											change_found_check=$change_found_check+1
										else	
											echo "less" >> $homepath/$Dir.txt
										fi
									else
										echo "less" >> $homepath/$Dir.txt
									fi # diff -gt
								fi
							fi # check for file with zero words
						fi #checking if variable contains only numbers
					fi # jpg
				fi # css or js
			fi #new file check
		fi # md5 equal
	done # html files

	rm find_file.txt
	if [[ $change_found_check > 0 ]]; then
		echo >> $homepath/result.txt	
		echo "$Dir CHANGED" >> $homepath/result.txt
		echo >> $homepath/result.txt
		echo "Changed: `grep -c "changed" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "New: `grep -c "new" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Same: `grep -c "same" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Less Changes: `grep -c "less" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "New css or js: `grep -c "n cssorjs" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Changed css or js: `grep -c "c cssorjs" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "All: $html" >> $homepath/result.txt
		echo >> $homepath/result.txt
		rm $homepath/$Dir.txt
		cd /mnt/rsyncbtrfs-master
		echo "********************    SnapShot      ********************" >> $homepath/result.txt
		sudo ./rsyncbtrfs backup /mnt/$Dir /mnt/$Dir$Snap >> $homepath/result.txt
		echo "************************************************************" >> $homepath/result.txt
		cd /mnt/$Dir$Snap

		ls | sort -r | grep "^[0-9]" > $homepath/db/$Dir/snapshot.txt
		cd $homepath/db/$Dir
		New=`sed -n '1p' snapshot.txt`
		echo >> $homepath/result.txt
		echo "************************************************************" >> $homepath/result.txt
		echo "IN DIRECTORY: $homepath/db/$Dir" >> $homepath/result.txt
		echo "$New CHANGES SAVED" >> $homepath/result.txt
		echo "************************************************************" >> $homepath/result.txt
		echo >> $homepath/result.txt
		mv -f $DATE.txt $New.txt
		mysql -u root -p"root1234" -D "WebArchive" -e "set @last_id = (select id from Page where page_url = '$Dir$Snap');insert into PageData(selected_page_id,snapshots_date) values (@last_id,'$New');" >> $homepath/result.txt
		rm snapshot.txt

	else
		echo
		echo "$Dir NO CHANGES" >> $homepath/result.txt
		echo >> $homepath/result.txt
		echo "Changed: `grep -c "changed" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "New: `grep -c "new" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Same: `grep -c "same" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Less Changes: `grep -c "less" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "New css or js: `grep -c "n cssorjs" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "Changed css or js: `grep -c "c cssorjs" $homepath/$Dir.txt`" >> $homepath/result.txt
		echo "All: $html" >> $homepath/result.txt
		echo >> $homepath/result.txt
		rm $homepath/$Dir.txt
		rm -rf $homepath/db/$Dir/$DATE.txt
	fi
	cd $homepath
else #cd pages/$Dir failed
	echo "$Dir page is not sent" >> $homepath/result.txt
fi # cd pages/$Dir
rm $homepath/error.txt
echo "/////////////////////////////////////////////////////////////" >> $homepath/result.txt
