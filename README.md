# Make Adwaita Great Again!

_... or at least tweakable._

# Modifications

## index.theme

* Description changes

## Gtk2 theme

Use `axxapy`'s `Adwaita-dark-gtk2` theme as the basis for the Gtk2 dark theme.

  * https://github.com/axxapy/Adwaita-dark-gtk2

This is set up as a submodule, so if you clone this repository, you need to execute: 

```
git submodule update --init --recursive
```

### gtk-2.0/

Most entries in the `gtk-2.0` directory are symlinks to their counterpars in
the `Adwaita-dark-gtk2/gtk-2.0` directory, except one.

#### gtk-2.0/gtkrc

* Add `gtk-color-scheme` variable:

```
gtk-color-scheme = "base_color:#efefef\nfg_color:#000000\ntooltip_fg_color:#000000\nselected_bg_color:#688060\nselected_fg_color:#ffffff\ntext_color:#000000\nbg_color:#dfdfdf\ninsensitive_bg_color:#F4F4F2\ntooltip_bg_color:#f5f5b5"
```

## Gtk3 Theme

### gtk-3.0

* settings.ini: Add `gtk-color-scheme` variable:

```
gtk-color-scheme = "base_color:#efefef;bg_color:#dfdfdf;tooltip_bg_color:#f5f5b5;selected_bg_color:#688060;text_color:#000000;fg_color:#000000;tooltip_fg_color:#000000;selected_fg_color:#ffffff;"
```

### Additional files in gtk-3.0:

#### Static:

  * `gtk.css`, `gtk-dark.css`:
  
    Ties together the original Adwaita theme, and the Zenburn-like modifications.  It ensures that:

    * The original Adwaita resources are read.
    * The Zenburn theme (base) colors are defined.
    * The Adwaita colors are re-defined as shades of the base colors.
    * Any overrides on the original Adwaita scheme are applied.

  * `gtk-zenburn-theme.css`, `gtk-zenburn-theme-dark.css`

    Defines the "theme" (base) colors of the theme, with the same values as the `gtk-color-scheme` configuration setting above.

  * `gtk-zenburn-overrides.css`, `gtk-zenburn-overrides-dark.css`

    Explicit overrides on top of the Adwaita scheme.

#### Generated:

  * `gtk-color-names.css`, `gtk-color-names-dark.css`

    Contains `@define-color` statements for each and every colour that is specified in the original theme (`gtk-contained.css` and `gtk-contained-dark.css`, resp.). Each unique colour gets its own name, e.g. `#cc0000` is defined as `color1`.

  * `gtk-zenburn-colors.css`, `gtk-zenburn-colors-dark.css`

    Contains the colours in the "`names`" files above, expressed as expressed as shades of the base theme colors.

# Creating the GTK-3 theme

## Unpack the gtk.gresource file

        cd gtk-3.0
        ../scripts/xtract_resource /lib64/libgtk-3.so

This unpacks the GTK resources file into the `org/gtk/libgt/theme/Adwaita`
sub-directory.

## Create symbolic names for all colours

Extract all literal color values and generate `@define-color` statements:

        ../scripts/prepare_colors

This will modify the theme's CSS files in org/gtk. For example:

        color: red;

Will be replaced by:

        color: @color19;

And `gtk-color-names.css` will contain:

        @define-color color19 #ff0000;

The same thing is done for dark theme files.

## (Re-)Define colours as shades of theme "base" colours

Look for all `@define-color` statements in the unpacked CSS files and express them as `shade()`-s of a few basic theme colors:

        ../scripts/mk_rel_colors normal > gtk-zenburn-colors.css
        ../scripts/mk_rel_colors dark   > gtk-zenburn-colors-dark.css

## Fix url("assets/...")

Make sure the asset URLs are set correctly. The original CSS files contain things like:

```
url("assets/checkbox-unchecked-dark.png")
```

Unfortunately that does not load (the extracted "png" file is not a PNG file but a raw GDK pixbuf dump), so to make it work properly, this has to be modified to read:

```
url("resource:///org/gtk/libgtk/theme/Adwaita/assets/checkbox-unchecked-dark.png")
```

To fix this, run the following command:

```
perl -p -i -e \
    's{url\("(assets/.*)"\)}
    {url("resource:///org/gtk/libgtk/theme/Adwaita/$1")}gx' \
    org/gtk/libgtk/theme/Adwaita/**/*.css
```
