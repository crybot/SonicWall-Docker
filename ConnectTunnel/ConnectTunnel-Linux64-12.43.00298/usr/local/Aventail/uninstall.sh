#!/bin/bash
XG_INSTDIR=/usr/local/Aventail
XG_PRODUCT="Connect Tunnel"

function nicever {
    read RAWVER
    echo "$RAWVER" | sed -re 's/^([0-9]+)\.([0-9])([0-9])[0-9]*\./\1.\2.\3./'
}

if [ "$UID" != "0" ]; then
    echo "This uninstaller needs to be run as root, you are $USER."
    echo -n "Try to uninstall anyway? (y/n)"
    read nonrootresponse
    if [ "$nonrootresponse" != "y" -a "$nonrootresponse" != "Y" ]; then
        exit 1
    fi
fi

cd /
if [ "$UID" == "0" ]; then
    echo "Uninstalling $XG_PRODUCT `cat $XG_INSTDIR/version | nicever`..."
else
    echo "Attempting to uninstall $XG_PRODUCT `cat $XG_INSTDIR/version | nicever`..."
fi

rm -f /usr/bin/startct
rm -f /usr/bin/startctui
rm -rf $XG_INSTDIR

for XGHOMEDIR in /home/* /root; do
    if [ -f "$XGHOMEDIR/Desktop/Connect Tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/Desktop/Connect Tunnel.desktop"
    fi
    if [ -f "$XGHOMEDIR/.gnome-desktop/Connect Tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/.gnome-desktop/Connect Tunnel.desktop"
    fi
    if [ -f "$XGHOMEDIR/.local/share/applications/Connect Tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/.local/share/applications/Connect Tunnel.desktop"
    fi
    if [ -f "$XGHOMEDIR/Desktop/connect-tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/Desktop/connect-tunnel.desktop"
    fi
    if [ -f "$XGHOMEDIR/.gnome-desktop/connect-tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/.gnome-desktop/connect-tunnel.desktop"
    fi
    if [ -f "$XGHOMEDIR/.local/share/applications/connect-tunnel.desktop" ]; then
        rm -f "$XGHOMEDIR/.local/share/applications/connect-tunnel.desktop"
    fi
done

if [ "$1" == "--purge-branding" ]; then
    echo "Purging branding files..."
    for XGHOMEDIR in /home/* /root; do
        rm -rf "$XGHOMEDIR/.sonicwall/AventailConnect/library/branding/"
    done
elif [ "$1" == "--purge-all" ]; then
    echo "Purging all files..."
    for XGHOMEDIR in /home/* /root; do
        rm -rf "$XGHOMEDIR/.sonicwall/AventailConnect/"
    done
fi

echo "$XG_PRODUCT uninstall complete."
