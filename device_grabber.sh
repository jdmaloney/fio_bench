#!/bin/bash

devices=($(lsscsi | awk '{print $6}' | grep /dev/))
num=$((${#devices[@]} - 1))

for i in $(seq -f "%02g" 0 $num)
do
	echo \[$i\]
	i=${i#0}
	echo filename=${devices[i]}
done

