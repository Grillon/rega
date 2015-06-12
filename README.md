REGA
====
Je ne sais plus pourquoi j'ai choisi ce nom mais je le garde. C'est un script de lancement d'extraction measureware.

Commandes
=========
CPU bottleneck
egrep -f cpu_bottleneck.data index_metrique.txt | awk -F\| '{if (!mesArg) {mesArg=$1} else {mesArg=mesArg","$1;}}END{print mesArg}'

contenu : 
=======

cpu_bottleneck
==============
GBL_CPU_TOTAL_UTIL
GBL_PRI_QUEUE
GBL_RUN_QUEUE

memory_bottleneck
=================
GBL_MEM_UTIL
GBL_MEM_QUEUE
GBL_MEM_PAGE_REQUEST_RATE
GBL_MEM_PAGE_REQUEST
GBL_MEM_PAGEOUT_RATE
GBL_MEM_PAGEOUT

disk_bottleneck
===============
GBL_DISK_UTIL_PEAK
GBL_BLOCKED_IO_QUEUE

global_queue
============
GBL_NET_OUTQUEUE
GBL_PRI_QUEUE
GBL_RUN_QUEUE
GBL_DISK_SUBSYSTEM_QUEUE
GBL_MEM_QUEUE
GBL_IPC_SUBSYSTEM_QUEUE
GBL_NETWORK_SUBSYSTEM_QUEUE
GBL_SLEEP_QUEUE
GBL_QUEUE_HISTOGRAM
