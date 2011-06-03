#!/bin/sh
FILENAME=$1
if [ -e .autotexlock ]; then
	rm .autotexlock
fi
while true; do
	MD5=$(md5sum "$FILENAME")
	if [ "$MD5" != "$OLDMD5" ] && ! [ -e .autotexlock ]; then
		touch .autotexlock
		if latex -interaction=nonstopmode "$FILENAME" 1>/dev/null; then
			pkill -USR1 xdvi
		fi
		rm .autotexlock
		OLDMD5=$MD5
	fi
	sleep .5s
done
