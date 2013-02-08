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
refIndex=/var/opt/perf/reptall
myrept=myrept

###############################
#    traitement des options   #
###############################

[ $# -lt 1 ] && {
	echo "Pour connaitre l'usage : $0 -h"
	exit 251
	}

while getopts "r:k:hdg" opt;do
	case ${opt} in
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
	extract -xp -gG -l /var/opt/perf/datafiles/logglob -r ${myrept}
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
