#!/bin/bash

# Creating the GTK-4 theme

## Unpack the gtk.gresource file

fatal() {
    echo "** FATAL: $@" >&2
    exit 1
}

find_libfile() {
    local fname="$1"
    local name="$2"
    local prog="$3"

    local libdir
    for libdir in /lib64 /lib
    do
        libfile="$libdir/$fname"
        if [[ -f $libfile ]]; then
            echo "$libfile"
            return 0
        fi
    done

    local progpath=$(which "$prog" 2>/dev/null)
    if [[ ! -n $progpath ]]; then
        echo "** cannot find $prog" >&2
        return 1
    fi

    libfile=$(ldd $(which "$prog") | grep "$name" | awk '{ print $3 }')
    if [[ ! -n $libfile ]]; then
        echo "** cannot find $name library" >&2
        return 1
    fi

    if [[ ! -r $libfile ]]; then
        echo "** cannot read $name library $libfile" >&2
        return 1
    fi
    echo $libfile
    return 0
}

GTK_LAUNCH=${1:-gtk4-launch}

mkdir -p gtk-4.0
cd gtk-4.0 || exit 1

libfile=$(find_libfile libgtk-4.so.0 gtk-4.so $GTK_LAUNCH)
[[ -n $libfile ]] || fatal "cannot continue"

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

# Extract GTK-4.0 library in "./org"
# This unpacks the GTK resources file into the
# `org/gtk/libgt/theme/Adwaita*` sub-directories.
echo "Extracting GTK resources from $libfile"
../scripts/xtract_resource $libfile || exit 1

# Try to find "libhandy", since it incorporates its own
# Adwaita-dark files. :-(
#mkdir -p sm/puri/handy/themes
#touch sm/puri/handy/themes/Adwaita-dark.css
#libfile=$(find_libfile libhandy-1.so.0 libhandy-1.so libsoup-2.4.so.1 gnome-clocks)
#echo "Extracting GTK resources from $libfile"
#[[ -n $libfile ]] && ../scripts/xtract_resource $libfile

# Try to find "libsoup", since it incorporates its own
# theme files. :-(
# libfile=$(find_libfile libsoup-2.4.so.1)
#mkdir -p gnome/libsoup
#touch gnome/libsoup/directory.css
#[[ -n $libfile ]] && ../scripts/xtract_resource $libfile

## Create symbolic names for all colours

# Extract all literal color values and generate `@define-color` statements:

mkdir -p generated || exit 1

orig_theme_dir=org/gtk/libgtk/theme/Adwaita
if [[ -d $orig_theme_dir ]]; then
    echo "Preparing colour definitions in $orig_theme_dir"
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

    echo "Creating relative (light) colours ->" \
         "generated/gtk-zenburn-colors.css"
    ../scripts/mk_rel_colors normal $orig_theme_dir generated \
        > generated/gtk-zenburn-colors.css

    echo "Creating relative (dark) colours ->" \
        "generated/gtk-zenburn-colors-dark.css"
    ../scripts/mk_rel_colors dark $orig_theme_dir generated \
        > generated/gtk-zenburn-colors-dark.css
else
    orig_theme_dir=org/gtk/libgtk/theme/Default
    echo "Preparing colour definitions in $orig_theme_dir"
    #../scripts/prepare_colors4 $orig_theme_dir generated -dark || exit 1
    ../scripts/prepare_colors $orig_theme_dir generated || exit 1

    #echo "Creating relative (dark) colours ->" \
    #    "generated/gtk-zenburn-colors-dark.css"
    #../scripts/mk_rel_colors dark $orig_theme_dir generated \
    #    > generated/gtk-zenburn-colors-dark.css
    echo "Creating relative (light) colours ->" \
         "generated/gtk-zenburn-colors.css"
    ../scripts/mk_rel_colors normal $orig_theme_dir generated \
        > generated/gtk-zenburn-colors.css

    echo "Creating relative (dark) colours ->" \
        "generated/gtk-zenburn-colors-dark.css"
    ../scripts/mk_rel_colors dark $orig_theme_dir generated \
        > generated/gtk-zenburn-colors-dark.css
fi

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

echo
echo "Fixing 'url(\"assets/...\") links in $orig_theme_dir"

perl -p -i -e \
    's{url\("(assets/[^"]*)"\)}
    {url("resource:///'$orig_theme_dir'/$1")}gx' \
    $(find $orig_theme_dir -name '*.css')

echo "inspected" $(find $orig_theme_dir -name '*.css' | wc -l) "files"
echo done
