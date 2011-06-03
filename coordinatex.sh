#!/bin/sh

# Copyright 2011 Daniel Thau. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#  CoordinaTeX
# ==============================================================================

# CoordinaTeX is a script which will automate compilation of a TeX file and
# forward searches (ie, having the output reader jump to the editor's cursor
# position).  The effect should be to get a seomwhat-live update of the TeX
# document as it is being created without having to manually make any requests
# for compilation or forward search syncing - just type your document and watch
# the reader update live and follow your cursor.


#  Functions
# ==============================================================================

# Quit CoordinaTeX cleanly, killing backgrounded functions
coordquit() {
	echo -n "Killing background functions"
	for PID in $1; do
		if kill $PID; then
			echo -n "."
		else
			echo "\nCouldn't kill background function, something could be wrong\n"
		fi
	done
#	if kill $COORDSEARCHPID; then
#		echo "Successfully killed sync loop"
#	else
#		echo "Couldn't kill sync loop, could be a problem."
#	fi
#	if kill $COORDCOMPILEPID; then
#		echo "Successfully killed compilation loop"
#	else
#		echo "Couldn't kill compilation loop, could be a problem."
#	fi
#	exit
}

print_help() {
	echo "CoordinaTeX 0.1\n"
	echo "usage: coordinatex [arguments]\n"
	echo "Arguments"
	echo "  -h              Print this dialogue"
	echo "  -i <filename>   TeX file to be edited and compiled"
	echo "  -o <filename>   Output file name"
	echo "  -e <editor>     Editor to forward search"
	echo "  -v <vimserver>  Vim's servername"
	exit
}

#  Main execution starts here
# ==============================================================================

echo "Starting CoordinaTeX"


#  Parse arguments
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

INFILE=""
OUTFILE=""
EDITOR=""
READER=""
VIMSERVER=""
while getopts ":hi:o:e:v:" OPT; do
	case "$OPT" in
		h | [?] ) print_help ;;
		i) INFILE="$OPTARG" ;;
		o) OUTFILE="$OPTARG" ;;
		e) EDITOR="$OPTARG" ;;
		r) READER="$OPTARG" ;;
		v) VIMSERVER="$OPTARG" ;;
	esac
done

#  Ensure required arguments were met, or warn about guesses
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

if [ -z "$INFILE" ]; then
	if [ $(ls | grep ".tex$" | wc -l) -eq 1 ]; then
		INFILE=$(ls | grep ".tex$")
		echo "WARNING: No infile specified, guessing $INFILE"
	else
		echo "ERROR: Must provide a TeX filename (to be edited and compiled)"
		exit
	fi
fi
if [ ! -f "$INFILE" ]; then
	echo "ERROR: Cannot find the file '$INFILE'"
	exit
fi
if [ -z "$OUTFILE" ]; then
	OUTFILE=$(echo $INFILE | sed 's/\(.*\).tex$/\1/')".dvi"
	echo "WARNING: No outfile specified, guessing: $OUTFILE"
fi
if [ -z "$EDITOR" ]; then
	if ps cx | grep vim >/dev/null; then
		EDITOR=vim
	elif ps cx | grep emacs >/dev/null; then
		EDITOR=emacs
	elif ps cx | grep gedit >/dev/null; then
		EDITOR=gedit
	fi
	if [ -z "$EDITOR" ]; then
		echo "ERROR: No editor specified, cannot guess, aborting"
		exit
	else
		echo "WARNING: No editor specified, guessing: $EDITOR"
	fi
fi
SUPPORTEDEDITORS="vim"
OKAYEDITOR=""
for VAR in $SUPPORTEDEDITORS; do
	if [ "$VAR" = "$EDITOR" ]; then
		OKAYEDITOR=1
	fi
done
if [ -z $OKAYEDITOR ]; then
	echo "ERROR: The editor '$EDITOR' is not currently supported."
	echo "Please select another editor with the -e option"
	echo "Currently supported editors are: $SUPPORTEDEDITORS"
	exit
fi
if  [ -z "$VIMSERVER" ] && [ "$EDITOR" = "vim" ]; then
	echo "ERROR: When using vim, must provide a vimserver name."
	echo "See vim's \":help clientserver\""
	exit
fi
SUPPORTEDREADERS="xdvi"
OKAYREADER=""
for VAR in $SUPPORTEDEDITORS; do
	if [ "$VAR" = "$READER" ]; then
		OKAYEDITOR=1
	fi
done
if [ -z $OKAYREADER ]; then
	echo "ERROR: The reader '$READER' is not currently supported."
	echo "Please select another reader with the -r option"
	echo "Currently supported readers are: $SUPPORTEDREADERS"
	exit
fi
if  [ -z "$VIMSERVER" ] && [ "$EDITOR" = "vim" ]; then
	echo "ERROR: When using vim, must provide a vimserver name."
	echo "See vim's \":help clientserver\""
	exit
fi

#case "$EDITOR-$READER" in
#	vim-xdvi )
#		READERLINE='xdvi --servername "$VIMSERVER --remote +%l +%f" -sourceposition "$CURSORPOS $INFILE" "$OUTFILE"'
#		;;
#	* )
#		echo "Missing needed information, aborting"
#		exit
#		;;
#esac
#export COORDCOMPILEPID="-1"
#export COORDSEARCHPID="-1"
#
#echo "done."
#
## don't want ctrl-c to quit without cleaning up
#trap coordquit INT
#
#echo -n "Starting automatic compilation loop... "
#coordcompile.sh "test.tex" "$EDITOR2"&
#COORDCOMPILEPID=$!
#if ps $COORDCOMPILEPID >/dev/null; then
#	echo "PID=$COORDCOMPILEPID"
#else
#	echo "Couldn't start compilation loop, aborting."
#	exit
#fi
#
#echo -n "Starting editor-viewer-sync loop... "
#coordsearch.sh "test.tex" "$EDITOR2"&
#COORDSEARCHPID=$!
#if ps $COORDSEARCHPID >/dev/null; then
#	echo "PID=$COORDSEARCHPID "
#else
#	echo "Couldn't start viewer loop, aborting."
#	exit
#fi
#
#
#echo "Press enter to quit"
#read DUMMYVAR
#
#coordquit
