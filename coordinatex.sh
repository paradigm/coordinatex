#!/bin/sh

# quit coordinatex cleanly, killing backgrounded loops
coordquit()
{
	echo "Cleaning up..."
	if kill $COORDSEARCHPID; then
		echo "Successfully killed sync loop"
	else
		echo "Couldn't kill sync loop, could be a problem."
	fi
	if kill $COORDCOMPILEPID; then
		echo "Successfully killed compilation loop"
	else
		echo "Couldn't kill compilation loop, could be a problem."
	fi
	exit
}

echo "Starting CoordinaTeX"
echo -n "Determining variables... "

# This is the TeX editor
EDITOR="vim"
# Other editor-related data, such as Vim's servername
EDITOR2="VIM1"
# PDF or DVI reader
READER="xdvi"
# Name of TeX file
INFILE="test.tex"
# Name of output file
OUTFILE="test.dvi"

case "$EDITOR-$READER" in
	vim-xdvi )
		READERLINE='xdvi --servername "$VIMSERVER --remote +%l +%f" -sourceposition "$CURSORPOS $FILENAME" "$OUTNAME"'
		;;
	* )
		echo "Missing needed information, aborting"
		exit
		;;
esac
export COORDCOMPILEPID="-1"
export COORDSEARCHPID="-1"

echo "done."

# don't want ctrl-c to quit without cleaning up
trap coordquit INT

echo -n "Starting automatic compilation loop... "
coordcompile.sh "test.tex" "$EDITOR2"&
COORDCOMPILEPID=$!
if ps $COORDCOMPILEPID >/dev/null; then
	echo "PID=$COORDCOMPILEPID"
else
	echo "Couldn't start compilation loop, aborting."
	exit
fi

echo -n "Starting editor-viewer-sync loop... "
coordsearch.sh "test.tex" "$EDITOR2"&
COORDSEARCHPID=$!
if ps $COORDSEARCHPID >/dev/null; then
	echo "PID=$COORDSEARCHPID "
else
	echo "Couldn't start viewer loop, aborting."
	exit
fi


echo "Press enter to quit"
read DUMMYVAR

coordquit





#./test.sh&
#TESTPID=$(echo $!)
#
#echo "Press enter to quit"
#read IGNOREME
#
#if kill $TESTPID; then
#	echo "Successfully killed TEST"
#else
#	echo "Couldn't kill TEST, something could be wrong"
#fi
