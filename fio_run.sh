#!/bin/bash

fio_path=fio/fio-2.1.10/fio
tests=('randrw' 'write' 'randwrite' 'read' 'randread')
bs=('4K' '512K' '1M')
op=("0M" "0M" "0M")

#printf '%-12s %16s %16s %16s \n' '' 4K 512K 1M > fio_out

echo Starting All Tests > fio_out
for t in ${tests[@]}
do
	echo Staring $t Tests >> fio_out
	for b in ${bs[@]}
	do
		if [ $b == 4K ]; then
			s=1G
		elif [ $b == 512k ]; then
			s=8G
		else
			s=32G
		fi
		echo Test for Block Size: $b >> fio_out
		i=0
		echo "[global]
		rw=$t
		bs=$b
		iodepth=16
		iodepth_batch=16
		iodepth_low=16
		ioengine=libaio
		direct=1
		size=$s
		group_reporting=1
		" > fio_config

		./device_grabber.sh >> fio_config

		echo "Running $t test with blocksize $b"
		echo 3 > /proc/sys/vm/drop_caches
		$fio_path fio_config 1> temp_output
		op[$i]=$(cat temp_output | grep aggrb)
		echo ${op[i]} >> fio_out
		#| awk '{print $3}' | cut -d'=' -f 2 | sed 's/.$//'
		i=$((i+1))
		rm -rf fio_config
	done
	#printf '%-12s %16s %16s %16s \n' $t ${op[0]} ${op[1]} ${op[2]} >> fio_out
done
rm -rf temp_output
