#!/bin/sh
# ISPsystem install v.4

Usage()
{
	cat << EOU >&2

Usage:
	$0 --help 	Print this help

	$0 [options] [mgrname]
	--os OS		Force use OS distribution
	--arch ARCH	Force use ARCH architecture
	--ip IP		Use IP for licence check
	--stable	Force install stable release
	
EOU
}

DetectFetch()
{
	if test -x /usr/bin/fetch; then
		fetch="/usr/bin/fetch -o "
	elif test -x /usr/bin/wget; then
		fetch="/usr/bin/wget -O "
	elif test -x /usr/bin/curl; then
		fetch="/usr/bin/curl -o "
	else
		echo "ERROR: no fetch program found."
		exit 1
	fi
}

DetectMd5()
{
	if test -x /sbin/md5; then
		md5="/sbin/md5 "
		isit=true
	elif test -x /usr/bin/md5sum; then
		md5="/usr/bin/md5sum "
		isit=false
	else
		echo "ERROR: no programm for checksum found."
		exit 1
	fi
}

DetectOS()
{
	kern=`uname -s`
	case "$kern" in
		FreeBSD)
			ver=`uname -r|sed -E 's/^([0-9]+\.[0-9]+).*$/\1/'`
			os="$kern-$ver"
			;;
		Darwin)
			os="Darwin"
			;;
		Linux)
			os="Linux-cc6"
#			if test -e "/usr/lib/libstdc++.so.7" -o -e "/usr/lib/libstdc++-v3/libstdc++.so.7"; then
#				os="Linux-cc7"
#			elif test -e "/usr/lib/libstdc++.so.6" -o -e "/usr/lib/libstdc++-v3/libstdc++.so.6"; then
#				os="Linux-cc6"
#			else
#				os="Linux-cc5"
#			fi	
			;;
		*)
			echo "Unknown OS type"
			exit 1
			;;
	esac
}

DetectArch()
{
	arch=`uname -m`
}

echo
echo "ISPsystem install v.4.4"
echo

while true
do
	case "$1" in 
		-h | --help)
			Usage
			exit 0
			;;
		--os)
			os=${2:-.}
			shift 2
			;;
		--arch)
			arch=${2:-.}
			shift 2
			;;
		--ip)
			ip=${2:-.}
			ipparam="ip=$ip"
			shift 2
			;;
		--stable)
			stable="true"
			shift 1
			;;
		-*)
			echo Unrecognized flag : "$1" >&2
			Usage
			exit 1
			;;
		*)
			break ;;
	esac
done

DetectFetch
DetectMd5

if test "$os" = ""; then
	DetectOS
fi

if test "$arch" = ""; then
	DetectArch
fi

if test $# -eq 0 ; then
	
#	if test "$list" = "no_license_found"; then
#		echo "You have no active licenses"
#		exit 1
#	fi


	mgrlist="ISPmanager BILLmanager VDSmanager IFXmanager DNSmanager IPmanager VMmanager"
	while true 
	do
		echo
		echo
		j="1"
		for i in $mgrlist; do
			echo "$j) $i"
			eval "mgrval$j=$i"
			j=$(($j+1))
		done

		echo "0) Exit"
		echo
		read -p "Please choose software to install: " n
		echo
		
		if test "$n" = "1"; then
			isplist="ISPmanager-Lite ISPmanager-Pro ISPmanager-Cluster";
			j="1"
			for i in $isplist; do
				echo "$j) $i"
				eval "ispval$j=$i"
				j=$(($j+1))
			done

			echo "0) Back"
			echo
			read -p "Please choose ISPmanager version: " v
			echo

			if test "$v" != "0"; then
				eval mgrname=\$ispval$v
			fi
		
		elif test "$n" = "2"; then
			billlist="BILLmanager-Standart BILLmanager-Advanced BILLmanager-Corporate BILLmanager-RUCENTER";
			j="1"
			for i in $billlist; do
				echo "$j) $i"
				eval "ispval$j=$i"
				j=$(($j+1))
			done

			echo "0) Back"
			echo
			read -p "Please choose BILLmanager version: " v
			echo

			if test "$v" != "0"; then
				eval mgrname=\$ispval$v
			fi
		elif test "$n" = "3"; then
			kern=`uname -s`
			case "$kern" in
				FreeBSD)
					mgrname="VDSmanager-FreeBSD"
					;;
				Linux)
					mgrname="VDSmanager-Linux"
					;;
				*)
					echo "VDSmanager not available for this OS"
					exit 1
					;;
			esac

		elif test "$n" = "0"; then
			exit 0
		else
			eval mgrname=\$mgrval$n
			echo $mgrname
		fi
	
		if test "$mgrname" != ""; then
			break;
		fi
	done
else
	mgrname=$1
fi

# check licence 
while true
do
	echo "Checking license ..."
	activelist=`$fetch - -q "http://lic.ispsystem.com/liclist.cgi?$ipparam"`
	for i in $activelist; do
		if test "$mgrname" = "$i"; then
			ok="1"
		fi
	done

	if test "$ok" = "1"; then
		break
	fi

	if test "$mgrname" = "ISPmanager-Lite"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=5%20period=2"
	elif test "$mgrname" = "ISPmanager-Pro"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=9%20period=10"
	elif test "$mgrname" = "ISPmanager-Cluster"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=112%20period=68"
	elif test "$mgrname" = "BILLmanager-Standart"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=432%20period=246"
	elif test "$mgrname" = "BILLmanager-Advanced"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=434%20period=247"
	elif test "$mgrname" = "BILLmanager-Corporate"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=435%20period=248"
	elif test "$mgrname" = "VDSmanager-FreeBSD"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=884%20period=534"
	elif test "$mgrname" = "VDSmanager-Linux"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=15%20period=24"
	elif test "$mgrname" = "DNSmanager"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=3136%20period=1926"
	elif test "$mgrname" = "IPmanager"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=2891%20period=1814"
	elif test "$mgrname" = "IFXmanager"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=3193%20period=1951"
	elif test "$mgrname" = "VMmanager"; then
		url="https://my.ispsystem.com/manager/billmgr?func=register&project=1&welcomfunc=software.order&welcomparam=price=3045%20period=1898"
	fi

	echo
	echo "You don't have the active license for this server."
    echo "Please, use the following URL to order a trial $mgrname license"
	echo "$url"
	echo "Moreover, you may specify another ip using the  --ip option."
	echo "When you order the license, press the Enter button to continue or Ctrl+C to abort installation."
	read t
done

if test -x /usr/bin/ntpdate; then
	/usr/bin/ntpdate -b pool.ntp.org
fi

tmpdir="/tmp/$mgrname"
mkdir -p $tmpdir
cd $tmpdir

if test "$n" = "4" || test "$n" = "5" || test "$n" = "6" || test "$n" = "7"; then
	read -p "What version of product do You want install: 4 or 5 ?" cv
	if test "$cv" = "5"; then
		shfile=$tmpdir/install.5.sh
		shurl="http://download.ispsystem.com/install.5.sh"
		$fetch $shfile "$shurl"
		clear
		sh $shfile
		exit 0
	fi
fi


goon="true"
while [ $goon = "true" ]
do
	goon="false"
	echo "1) ru.download.ispsystem.com"
	echo "2) us.download.ispsystem.com"
	echo "3) be.download.ispsystem.com"
	echo
	read -p "Please choose mirror to install from: " n
	echo

	if [ "$n" = "1" ]; then mirror="ru.download.ispsystem.com"
	elif [ "$n" = "2" ]; then mirror="us.download.ispsystem.com"
	elif [ "$n" = "3" ]; then mirror="be.download.ispsystem.com"
	else goon="true"; fi
done

#stable="false"
goon="true"
while [ $goon = "true" ]
do
    goon="false"
	if [ "$stable" = "true" ]; then
			url="http://$mirror/$os/$arch/$mgrname/install.tgz"
	else
		echo "1) beta version - has the latest functionality"
		echo "2) stable version - time-proved version"
		echo
		read -p "Please choose version to install: " n
		echo
		if [ "$n" = "1" ]; then 
			url="http://$mirror/$os/$arch/$mgrname/install.tgz"
		elif [ "$n" = "2" ]; then
			url="http://$mirror/$os/$arch/$mgrname/install.stable.tgz"
			stable="true";
		else goon="true"; fi
	fi
done

archive="$tmpdir/install.tgz"

test -f $archive && rm -f $archive
$fetch $archive "$url"

if ! test -s $archive; then
	echo "Can't download $mgrname distribution"
	echo "Make sure it is available for your platform ($os $arch)"
	echo "List of supported distribution you can see at"
	echo "http://download.ispsystem.com/"
	echo "see $0 --help for more information"
	rm -rf $tmpdir
	exit 1
fi

# check md5
$fetch $archive.md5 "$url.md5"

if test "$isit" = "true"; then
	remotesum=`cat $archive.md5 | awk '{print $4}'`
	localsum=`$md5 install.tgz | awk '{print $4}'`
else
	remotesum=`cat $archive.md5 | awk '{print $1}'`
	localsum=`$md5 install.tgz | awk '{print $1}'`
fi

if test "$localsum" != "$remotesum"; then
	echo "Invalid MD5 signature"
	echo "Please try again."
	rm -rf $tmpdir
	exit 1
fi

mgrdir="/usr/local/ispmgr/"
mkdir -p $mgrdir
cd $mgrdir
bin=`tar xvzpf $archive 2>&1 | grep -v 'sbin' | grep 'bin/.' | sed -e 's/^.*\///'`
rm -rf $tmpdir

echo "Mirror http://$mirror/" >> $mgrdir/etc/dist/$bin.conf
if test "$stable" = "true"; then
	echo "Release stable" >> $mgrdir/etc/dist/$bin.conf
fi

installname=`echo ${mgrname} | sed -e 's/-.*$//'`

if test "$installname" = "ISPmanager"; then
	$fetch etc/ispmgr.lic -q "http://lic.ispsystem.com/ispmgr.lic?$ipparam"
fi

#sh sbin/${installname}-install.sh $mirror $ip
cd sbin
./ispinstall -s -c apache -c nginx -c ftp -c smtp -c pop3 -c dns -c php -c myadmin
