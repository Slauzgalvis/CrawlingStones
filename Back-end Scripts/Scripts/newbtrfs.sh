#!/bin/bash


Snap=_Snapshot
homepath=`pwd`
Dir=`sed -n "1p" downloaded_page.txt`
if [ -d "/mnt/$Dir" ]; then
	echo "/mnt/$Dir Exist"
else
	if [ -d "pages/$Dir" ];then
		echo "/mnt/$Dir does not Exist"
		page_name=`wget --quiet -O - $Dir| paste -s -d " "| sed -n -e 's!.*<head[^>]*>\(.*\)</head>.*!\1!p'| sed -n -e 's!.*<title>\(.*\)</title>.*!\1!p'|cut -f1 -d"-"`
		mysql -u root -p"root1234" -D "WebArchive" -e "insert into Page(page_name, page_url) values('$page_name','$Dir$Snap');"
		mkdir $homepath/db/$Dir
		sudo cp -r pages/$Dir /mnt/$Dir
		sudo mkdir /mnt/$Dir$Snap
		cd /mnt/rsyncbtrfs-master
		sudo ./rsyncbtrfs init ../$Dir$Snap
		echo "********************    SnapShot      ********************" >> $homepath/result.txt
		sudo ./rsyncbtrfs backup /mnt/$Dir /mnt/$Dir$Snap >> $homepath/result.txt
		echo "************************************************************" >> $homepath/result.txt
		ls /mnt/$Dir$Snap | sort -r | grep "^[0-9]" > $homepath/snapshot.txt
		cd $homepath
		New=`sed -n '1p' snapshot.txt`
		rm snapshot.txt
		mysql -u root -p"root1234" -D "WebArchive" -e "set @last_id = (select id from Page where page_url = '$Dir$Snap');insert into PageData(selected_page_id,snapshots_date) values (@last_id,'$New');" >> $homepath/result.txt
	fi
fi
if [ -d "/mnt/$Dir$Snap" ]; then
	:
else
	sudo mkdir /mnt/$Dir$Snap
fi
