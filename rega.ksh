#!/bin/ksh
###############################
# /!\ Attention ce programme  #
# est une ibauche irreflechie #
# faite par un homme presse   #
#    utilisation a risque     #
###############################

###############################
#    definition variable      #
###############################

extractionH=xfrsGLOBAL.asc
extractionM=xfrdGLOBAL.asc
extraction=${extractionH}
index=index_metrique.txt
logglob=/var/opt/perf/datafiles/logglob
refIndex=/var/opt/perf/reptall
myrept=myrept

###############################
#    traitement des options   #
###############################

[ $# -lt 1 ] && {
	echo "Pour connaitre l'usage : $0 -h"
	exit 251
	}

while getopts "r:k:hdgp:" opt;do
	case ${opt} in
		p)#profil
		case ${OPTARG} in
		cpuB)colonnes="GBL_CPU_TOTAL_UTIL|GBL_PRI_QUEUE|GBL_RUN_QUEUE"
		;;
		memB)
		colonnes="GBL_MEM_UTIL|GBL_MEM_QUEUE|GBL_MEM_PAGE_REQUEST_RATE|GBL_MEM_PAGE_REQUEST|GBL_MEM_PAGEOUT_RATE|GBL_MEM_PAGEOUT"
		;;
		diskB)
		colonnes="GBL_DISK_UTIL_PEAK|GBL_BLOCKED_IO_QUEUE"
		;;
		netU)
		colonnes="GBL_NUM_NETWORK|GBL_NET_ERROR_1_MIN_RATE|GBL_NET_COLLISION_1_MIN_RATE|GBL_NET_IN_ERROR_PCT|GBL_NET_OUT_ERROR_PCT|GBL_NET_OUTQUEUE|GBL_NET_IN_PACKET_RATE|GBL_NET_IN_PACKET|GBL_NET_OUT_PACKET_RATE|GBL_NET_OUT_PACKET|GBL_NET_PACKET_RATE|GBL_NET_COLLISION_PCT|GBL_NETWORK_SUBSYSTEM_QUEUE"
		;;
		queue)
		colonnes="GBL_NET_OUTQUEUE|GBL_PRI_QUEUE|GBL_RUN_QUEUE|GBL_DISK_SUBSYSTEM_QUEUE|GBL_MEM_QUEUE|GBL_IPC_SUBSYSTEM_QUEUE|GBL_NETWORK_SUBSYSTEM_QUEUE|GBL_SLEEP_QUEUE|GBL_QUEUE_HISTOGRAM"
		;;
		allBQ)
		colonnes="GBL_NET_OUTQUEUE|GBL_PRI_QUEUE|GBL_RUN_QUEUE|GBL_DISK_SUBSYSTEM_QUEUE|GBL_MEM_QUEUE|GBL_IPC_SUBSYSTEM_QUEUE|GBL_NETWORK_SUBSYSTEM_QUEUE|GBL_SLEEP_QUEUE|GBL_QUEUE_HISTOGRAM"
		colonnes=$colonnes"|GBL_DISK_UTIL_PEAK|GBL_BLOCKED_IO_QUEUE"
		colonnes=$colonnes"|GBL_MEM_UTIL|GBL_MEM_QUEUE|GBL_MEM_PAGE_REQUEST_RATE|GBL_MEM_PAGE_REQUEST|GBL_MEM_PAGEOUT_RATE|GBL_MEM_PAGEOUT"
		colonnes=$colonnes"|GBL_CPU_TOTAL_UTIL|GBL_PRI_QUEUE|GBL_RUN_QUEUE"
		;;
		esac
		colonnes=$(egrep "$colonnes" index_metrique.txt | awk -F\| '{if (!mesArg) {mesArg=$1} else {mesArg=mesArg","$1;}}END{print mesArg}')
		colonnes=3,4,${colonnes}
		;;
		r)#colonnes="${OPTARG}";;	
			colonnes=$(echo ",${OPTARG}," | sed -e 's/,[3-4],/,/g' -e 's/^,//' -e 's/,$//')
			colonnes=3,4,${colonnes};;
		k)cle="${OPTARG}";;
		d)detail=1;extraction=${extractionM};;
		g)gen=1;;
		h|*)echo "USAGE : $0 -r colonnes [-d] [-k cle] "
		  echo "colonnes : nbr separes par des virgules"
		  echo "-d : vue tt les 5 mn"
		  echo "cle : mot cle, ou un nombre"
		  echo "-----profiles----- : B pour bottleneck, U pour USAGE et Q pour Queue"
		  echo "-p : cpuB|memB|diskB|queue|allBQ|netU"
		  echo "-g : gen des extractions"
		   exit 251;;
	esac	
done
shift $((${OPTIND} - 1))
echo "-r=${colonnes},-k=${cle},-d=${detail},-g=${gen}" #debug

###############################
#    programme principal      #
###############################

[ "${gen}" -eq 1 ] && rm "${myrept}" "${index}" "${extractionM}" "${extractionH}"

if [ ! -s "${index}" ];then
	if [ -r "${refIndex}" ];then
		#cp ${refIndex} ${myrept}
awk '
	BEGIN { global=0 }
	{
		if (/^DATA TYPE GLOBAL$/) { global=1;}
		else if (/DATA TYPE APPLICATION$/) { global=0;}
		if (global==1) { if ($0 ~ /^\* [A-Z]*/) $0=substr($0,3); }
		print $0;
		}' ${refIndex}>${myrept}
		
	else 
		echo "le fichier de reference ${refIndex} n'existe pas"
		exit 252
	fi
	awk '
	{ 
		if (/^DATA TYPE GLOBAL$/) { global=1;}
                else if (/DATA TYPE APPLICATION$/) { global=0;nbr=0}
		else if (global == 1 && $0 ~ /^[A-Z]+/){nbr+=1;print nbr"|"$0}

	}' ${myrept}>${index}
fi
if [ ! -r "${extraction}" ];then 
	extract -xp -gG -l ${logglob} -r ${myrept}
	[ $? -gt 0 ] && echo "extraction impossible"
fi
if [ "${colonnes}" != "" ];then
	if [ "${cle}" != "" ];then 
		cut -d\| -f ${colonnes} ${extraction} | head -3
		cut -d\| -f ${colonnes} ${extraction} | grep ${cle}
	else 
		cut -d\| -f ${colonnes} ${extraction}
	fi
else  
	echo "Colonnes non precise! traitement impossible"
	exit 251
fi
exit 0;
