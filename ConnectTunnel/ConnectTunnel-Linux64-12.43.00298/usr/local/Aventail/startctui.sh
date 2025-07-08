#!/bin/bash

XG_UI_ARCHIVE=SnwlConnect.jar
xg_inst_dir=/usr/local/Aventail/ui

# If Java version predates this, we ask the user for confirmation before
# running.
XG_JAVA_REQD=11.0

if [ ! -f "$xg_inst_dir/$XG_UI_ARCHIVE" ]; then
    xg_inst_dir=.
fi

if [ ! -f "$xg_inst_dir/$XG_UI_ARCHIVE" ]; then
    echo "Connect Tunnel install is incomplete or corrupted." 1>&2
    exit 1
fi

function clean_up {
    exit
}
trap clean_up SIGINT SIGTERM

XG_INSTDIR=/usr/local/Aventail
XG_MODULE=$XG_INSTDIR/modules/`uname -r`/xgdynroute.ko

function warn_unsuitable_java {
    XG_CURRJVER=$1

    if [ "$XG_CURRJVER" != "" ]; then
        XG_CURRJVER=" ($XG_CURRJVER)"
    fi

    if [ -x "`which zenity 2>/dev/null`" ]; then
        msg="Connect Tunnel needs Java $XG_JAVA_REQD or \
newer; your Java$XG_CURRJVER appears unsuitable.
Try to run anyway?"
        zenity --question --title "Confirm" --text "$msg"
        return $?
    fi

    return 0
}

function xg_check_java {
    XG_JAVA_VERSION=`java -version 2>&1 |
            perl -lne '($_) = /"([\d._]+)"/; print if $_'`

    if [ "`java -version 2>&1`" == "" -o \
            "$XG_JAVA_VERSION" == "" ]; then
        warn_unsuitable_java
        return $?
    fi

    perl -e '($c, $e) = map { s/(\d+)[._]?/chr($1)/ge; $_ } @ARGV;
             exit(1) unless $c ge $e' \
             $XG_JAVA_VERSION $XG_JAVA_REQD
    if [ "$?" != "0" ]; then
        warn_unsuitable_java $XG_JAVA_VERSION
        return $?
    fi

    return 0
}

for cmdopt in $*; do
    if [ "$cmdopt" == "-d" ]; then
        XG_DEBUG="-Dapplication.mode=debug"
    elif [ "$cmdopt" == "-dpi" ]; then
        XG_SCALE="-Dsun.java2d.uiScale=2.0"
    fi
done

# Check for java
if [ ! -x "`which java 2>/dev/null`" ]; then
    echo "Connect Tunnel cannot start: java is not in PATH ($PATH)"
    echo "If java is already installed, please place a link to it in this PATH"
    exit 1
fi

xg_check_java || exit 1

java $XG_DEBUG $XG_SCALE -jar "$xg_inst_dir/$XG_UI_ARCHIVE" --mode gui
