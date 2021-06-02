#!/bin/bash

dfl_gtk_v=$(gtk-launch --version)

case $dfl_gtk_v in
    3.*)
        echo '=== Fixing GTK3 theme'
        ./make_theme-gtk3.sh gtk-launch

        if which gtk4-launch >/dev/null 2>&1; then
            echo '=== Fixing GTK4 theme'
            ./make_theme-gtk4.sh gtk4-launch
        else
            echo '=== Skipping GTK4 theme'
        fi
        ;;
    4.*)
        echo '=== Fixing GTK4 theme'
        ./make_theme-gtk4.sh gtk-launch
        if which gtk3-launch >/dev/null 2>&1; then
            echo '=== Fixing GTK3 theme'
            ./make_theme-gtk3.sh gtk3-launch
        else
            echo '=== Skipping GTK3 theme'
        fi
        ;;
    *)
        echo '** ERROR: Unknown GTK version installed' >&2
        exit 1
        ;;
esac
