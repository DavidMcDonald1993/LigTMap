#!/bin/sh

#
# --- TSRI, Michel Sanner Copyright 2004 ---
#

######
## Set some environment variable.
MGL_ROOT="/home/david/MGLTools-1.5.6" 
export MGL_ROOT

########
## plaform we run on
##
MGL_ARCHOSV=`$MGL_ROOT/bin/archosv`
export MGL_ARCHOSV

#######
## path to the extralibs directory.
##
MGL_EXTRALIBS="$MGL_ROOT/lib"
export MGL_EXTRALIBS

#######
## path to the extrainclude directory
MGL_EXTRAINCLUDE="$MGL_ROOT/include"
export MGL_EXTRAINCLUDE


########
## add the path to the directory holding the python interpreter to your path
##
PATH="$MGL_ROOT/bin:$PATH"
export PATH


TCL_LIBRARY="$MGL_ROOT/tcl8.4"
export TCL_LIBRARY

TK_LIBRARY="$MGL_ROOT/tk8.4"
export TK_LIBRARY

# set path so we get the versions of command we expect
originalpath="$PATH"

# set the LD_LIBRARY PATH for each platform
case "`uname -s`" in
    IRIX|IRIX64)
	LD_LIBRARYN32_PATH="$MGL_ROOT/lib${LD_LIBRARYN32_PATH:+:$LD_LIBRARYN32_PATH}"
	export LD_LIBRARYN32_PATH
	;;
    OSF1)
	LD_LIBRARY_PATH="$MGL_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	export LD_LIBRARY_PATH
	;;
    Linux)
	LD_LIBRARY_PATH="$MGL_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	export LD_LIBRARY_PATH
	;;
    Darwin*)
        # NOTE: the user may have already set DISPLAY, so don't change it    
        if [ ! "$DISPLAY" ]; then
            DISPLAY=":0.0"
            export DISPLAY
        fi
        # If the X11 is not running, modify .xinitrc to remove xterm
        # This assumes X11 is installed!
        ps -wx -ocommand | grep -e '[X]11' > /dev/null;
        if [ \"$?\" != \"0\" -a ! -f ~/.xinitrc ]; then
            echo \"rm -f ~/.xinitrc\" > ~/.xinitrc
            sed 's/xterm/# xterm/' /usr/X11R6/lib/X11/xinit/xinitrc >> ~/.xinitrc                 
        fi 
	# This will start X11 which provides windows system.
	# which is needed to run ADT/PMV and VISION
	echo "Starting X11"
	open -a X11
	DYLD_LIBRARY_PATH="$MGL_ROOT/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
	export DYLD_LIBRARY_PATH
	# Make the Tcl/Tk and Python frameworks accessible.
	# DYLD_FRAMEWORK_PATH="$CHIMERA/Library/Frameworks${DYLD_FRAMEWORK_PATH:+:$DYLD_FRAMEWORK_PATH}"
	# export DYLD_FRAMEWORK_PATH
	# Chimera hangs on start-up on Mac OS 10.2 due to a semaphore lock
	# in the run-time linker unless the following variable is set.
	# DYLD_BIND_AT_LAUNCH=1
	# export DYLD_BIND_AT_LAUNCH
	;;
    SunOS)
	LD_LIBRARY_PATH="$MGL_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	export LD_LIBRARY_PATH
	;;
esac


# system-dependent error checking
case "`uname -s`" in
	IRIX|IRIX64)
		;;
	OSF1)
		;;
	Linux)
		p0="/usr/lib/libGL.so.1"
		p1="/usr/X11R6/lib/libGL.so.1"
		if [ -f "$p0" -a -f "$p1" ]
		then
			ls0=`ls -Ll "$p0" | sed 's,/.*,,'`
			ls1=`ls -Ll "$p1" | sed 's,/.*,,'`
			if [ "$ls0" != "$ls1" ]
			then
				echo "OpenGL misconfiguration detected."
				echo "Please reinstall graphics driver."
				#exit 1
			fi
		fi
		;;
	AIX*)
		;;
	Darwin*)
		;;
esac
 
# deduce any flags we want to pass to python
pyflags=""
for i in "$@"
do
	case $i in
	--opt)
		pyflags="$pyflags${pyflags:+ }-OO"
		# remove '--opt' from list of args
		shift
		;;
	esac
done

# deduce which python to use
if test -x "$MGL_ROOT/bin/python"
then
	# using our distributed version of python, don't use any python
	# environment variables, especialy PYTHONHOME and PYTHONPATH
	unset PYTHONHOME
	echo "setting PYTHONHOME environment"
	PYTHONHOME="$MGL_ROOT"
	export PYTHONHOME
	PYTHONPATH="$MGL_ROOT/MGLToolsPckgs"
	export PYTHONPATH
	#python="$MGL_ROOT/bin/python -i"
	python="$MGL_ROOT/bin/python"
else
	PATH="$originalpath"
	#python="python -i"
	python="python"
fi
