#!/bin/bash

# Creating the GTK-3 theme

## Unpack the gtk.gresource file

libfile=/lib64/libgtk-3.so.0
if [[ -f /lib64/libgtk-3.so.0 ]]; then
    libfile=/lib64/libgtk-3.so.0
elif [[ -f /lib/libgtk-3.so.0 ]]; then
    libfile=/lib/libgtk-3.so.0
else
    libfile=$(ldd $(which gtk-launch) | grep libgtk-3.so | awk '{ print $3 }')
    if [[ ! -n $libfile ]]; then
        echo "** FATAL: cannot find Gtk3 library" >&2
        exit 1
    elif [[ ! -r $libfile ]]; then
        echo "** FATAL: cannot read Gtk3 library $libfile" >&2
        exit 1
    fi
fi

mkdir -p gtk-3.0
cd gtk-3.0 || exit 1

orig_theme_dir=org/gtk/libgtk/theme/Adwaita

backup_stamp=$(date +%Y%m%d-%H%M%S)
if [[ -e org ]]; then
    bak=org.$backup_stamp.bak
    [[ ! -e $bak ]] || rm -r "$bak" || exit 1
    mv org $bak || exit 1
fi

if [[ -e generated ]]; then
    bak=generated.$backup_stamp.bak
    [[ ! -e $bak ]] || rm -r "$bak" || exit 1
    mv generated $bak || exit 1
fi

# Extract in "./org"
../scripts/xtract_resource $libfile

# This unpacks the GTK resources file into the
# `org/gtk/libgt/theme/Adwaita` sub-directory.

## Create symbolic names for all colours

# Extract all literal color values and generate `@define-color` statements:

mkdir -p generated || exit 1

../scripts/prepare_colors $orig_theme_dir generated || exit 1
# ^^^^^^^^^^^^^^^^^^^^^^^
# This will modify the theme's CSS files in org/gtk. For example:
# "color: red;" will be replaced by "color: @color19", and
# "generated/gtk-color-names.css" will contain:
# "@define-color color19 #ff0000".
#
# The same thing is done for dark theme files.

## (Re-)Define colours as shades of theme "base" colours

# Look for all "@define-color" statements in the unpacked CSS
# files and express them as "shade()"-s of a few basic theme colors:

../scripts/mk_rel_colors normal $orig_theme_dir generated \
    > generated/gtk-zenburn-colors.css

../scripts/mk_rel_colors dark $orig_theme_dir generated \
    > generated/gtk-zenburn-colors-dark.css

## Fix url("assets/...")

# Make sure the asset URLs are set correctly. The original CSS files
# contain things like:
#
#   url("assets/checkbox-unchecked-dark.png")
#
# Unfortunately that does not load (the extracted "png" file is not
# a PNG file but a raw GDK pixbuf dump), so to make it work properly,
# this has to be modified to read:
#
#   url("resource:///org/gtk/libgtk/theme/Adwaita/assets/checkbox-unchecked-dark.png")
#
# Yes, that's a mouthful. ;-)

perl -p -i -e \
    's{url\("(assets/.*)"\)}
    {url("resource:///org/gtk/libgtk/theme/Adwaita/$1")}gx' \
    $(find $orig_theme_dir -name '*.css')
