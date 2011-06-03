#!/bin/sh
FILENAME=$1
OUTNAME=$(echo $FILENAME | sed 's/\(.*\).tex$/\1.dvi/')
VIMSERVER=$2
OLDCURSOR=""
while true; do
	CURSORPOS=$(vim --servername "$VIMSERVER" --remote-expr 'line(".").":".col(".")')
	if [ "$CURSORPOS" != "$OLDCURSOR" ]; then
		xdvi -watchfile 1 -editor "vim --servername $VIMSERVER --remote +%l %f" -sourceposition "$CURSORPOS$FILENAME" "$OUTNAME"
		OLDCURSOR=$CURSORPOS
	fi
	sleep .10s
done
