#! /bin/sh

########################################
# Name: Project Lock
#
# about:Project directory lock to avoid confliction.
#
# Usage: ./plock.sh [-l|-u] [user] [comment]
#
# Author:yacohana
# Date:01/12/2014
########################################

LOCKFILEDIR="/home/hogehoge/plock/"
LOCKFILE="lock.lock"

unset -f unalias
\unalias -a
unset -f command

SYSPATH="$(command -p getconf PATH 2>/dev/null)"
if [[ -z "$SYSPATH" ]] ; then
	SYSPATH="/usr/bin:/bin"
fi
PATH=$SYSPATH:$PATH

if ! (( [ -w "$LOCKFILEDIR$LOCKFILE" ] )||( !( [ -e "$LOCKFILEDIR$LOCKFILE" ] ) && [ -w "$LOCKFILEDIR" ] )) ; then
	echo "Error: File permittion error." 1>&2
	exit 1
fi

usage_exit() {
	echo "	Usage: $0 [-l|-u] [user] [comment]" 1>&2
	echo "	Options:" 1>&2
	echo "	-l		set mode lock(optional)" 1>&2
	echo "	-u		set mode unlock(optional)" 1>&2
	echo "	user		input name. if empty, only check lock status." 1>&2
	echo "	comment		input commnent(optional)" 1>&2
	exit 1
}

MODE=3 #default(auto select)

while getopts "luh" OPT
do
	case $OPT in
		l)	MODE=1
			;;
		u)	if [ "$MODE" -ne 1 ] ; then
				MODE=0
			else
				echo "Error: you cannot option -l and -u together." 1>&2
				usage_exit
			fi
			;;
		h)	usage_exit
			;;
		\?)	usage_exit
		;;
	esac
done
shift $((OPTIND-1))

USER="$1"
shift
COMMENT="$@"

if [ -f "$LOCKFILEDIR$LOCKFILE" ] ; then
	LOCKUSER=`head $LOCKFILEDIR$LOCKFILE -n 1`
fi

if (( [ ! $USER ] )&&( [ "$MODE" -eq 1 ] )) ; then
	echo "Error: input no name."
	exit 1
fi
if (( [ $USER ] )&&( [ "$MODE" -eq 3 ] )) ; then
	if [ "$USER" = "$LOCKUSER" ] ; then
		MODE=0
	else
		MODE=1
	fi
fi

if [ "$MODE" -eq 3 ] ; then
	MODE=2
fi

case $MODE in
	0)	if [ ! $LOCKUSER ] ; then
			echo "Error: not locked now." 1>&2
			exit 1;
		fi
		if [ "$USER" != "$LOCKUSER" ] ; then
			echo "you are not the locking user $LOCKUSER." 1>&2
			echo "Really do you overwrite? [y/n]" 1>&2
			read ANSWER
			case `echo $ANSWER | tr y Y` in
			    "" | Y*	)	echo "->Overwrite, continue." 1>&2 
							;;
				*		)	echo "Error: user stop." 1>&2
							exit 1
							;;
			esac
		fi
		cat "/dev/null" >$LOCKFILEDIR$LOCKFILE
		echo "Unlock, success." 1>&2
		;;
	1)	if ([ $LOCKUSER ])&&([ "$USER" != "$LOCKUSER" ])  ; then
			echo "Error: locked now. If you want to overwrite, try to unlock." 1>&2
			exit 1;
		fi
		if [ "$USER" = "$LOCKUSER" ] ; then
			echo "you did already lock." 1>&2
			echo "Really do you overwrite? [y/n]" 1>&2
			read ANSWER
			case `echo $ANSWER | tr y Y` in
			    "" | Y*	)	echo "->Overwrite, continue." 1>&2 
							;;
				*		)	echo "Error: user stop." 1>&2
							exit 1
							;;
			esac
		fi
		DATE=`date`
		echo "$USER
$DATE
$COMMENT" > $LOCKFILEDIR$LOCKFILE
		echo "Locked by $USER, success." 1>&2
		;;
	2) echo "Now lock status is.." 1>&2
		if [ -s "$LOCKFILEDIR$LOCKFILE" ] ; then
			cat $LOCKFILEDIR$LOCKFILE
		else
			echo "Not locked." 1>&2
		fi;;
esac

exit 0

