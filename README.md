# Make Adwaita Great Again!

_... or at least tweakable._

***NOTE: These tweaks are optimised for dark themes only (Zenburn being a dark theme)***

The Adwaita theme is now the default theme for Gnome3 and its "dark" version is fine for most uses.
However, I don't agree with all color choices, and would like to add a bit of Zenburn to it (mostly green for highlighting, rather than blue).

Gnome2 and Gtk2 used to support setting the `gtk-color-scheme` variable (in `gtkrc`), that allowed color tweaks to stock themes, by changing a limited set of base colors.

Since Gtk3 moved to CSS, this is no longer possible. To make any tweaks, one has to copy the theme files to one's `~/.themes` directory, and modify the colors in the CSS files. That in itself wouldn't be so bad if only the theme were expressed in shades of the base colors. That's not the case, unfortunately. The CSS files of the Adwaita dark theme alone contain 110 unique colors (the light theme 102), each one specified as a literal RGB value.

Of course, what we get in our distributed themes is a compiled version of the Adwaita sources, which I'm sure are full of macros and handy tools. The thing is, I don't want to set up a complete tool chain just to tweak a few colors.

So, I came up with another approach:

 * Define a set of base colors for the theme.
 * Express all other colors as shades of these base colors.

With that done, a tweak of a single base color *should* modify related colors in a way that is hopefully not too jarring.

All I can say is, "it works for me", but YMMV, and I'm fairly sure the whole thing breaks down when you make extreme color modifications.

So, below I'll outline what I did, along with instructions on reproducing this.

# Compatibility

Works for me on:

 * GNOME 3.24 through GNOME 3.34

# Requirements

## gnome-tweaks

In order to select and activate the tweaked theme, you need the `gnome-tweaks` tool installed.

 * Fedora/RHEL/CentOS: `sudo dnf install gnome-tweaks`
 * Debian/Ubuntu: `sudo apt install gnome-tweaks`

## gresource

The `gresource` utility is needed to extract the CSS resources from the compiled Adwaita resource file (either a `.gtkresource` file or the GTK+ 3 shared library).

For Fedora, `gresource` is included in `glib2-devel`:
```
sudo dnf install glib2-devel
```

For Debian/Ubuntu, `gresource` is included in `libglib2.0-bin`:
```
sudo apt install libglib2.0-bin
```

# Installation

## Clone the repository

First clone the repository to your own environment:

```
mkdir -p ~/.themes
cd ~/.themes
git clone https://github.com/sbakker/Adwaita-Steven.git Adwaita-Tweaked
cd Adwaita-Tweaked
# Needed for pulling in `axxapy`'s `Adwaita-dark-gtk2` theme.
git submodule update --init --recursive
```

## Create the GTK-3 theme

```
cd ~/.themes/Adwaita-Tweaked
./make_theme.sh
```

This will extract/copy the Adwaita theme to the `Adwaita-Tweaked` directory and modify the CSS files to express all colors as shades of the base colors.

See the script itself for more details.

## Activating the theme

 * Start `gnome-tweaks`
 * In the *Appearance* tab, under *Themes*, the dropdown menu for *Applications* should now contain *Adwaita-Tweaked*
 * Select *Adwaita-Tweaked* for *Applications*

## Customising the theme

### GTK-3

As mentioned above, the theme is expressed as shades of a limited set of base colors. These base colors are defined in `gtk-3.0/gtk-zenburn-theme-dark.css`. This file contains 25 color definitions, but most color definitions refer to others, and in the end, there are only 7 colors directly expressed as RGB values.

The `gtk-3.0/gtk-zenburn-overrides-dark.css` contains some overrides for a few applications that don't work well with the tweaked theme, or dark themes in general (Evolution being one of them). You probably don't have to touch this.

### GTK-2

Legacy (GNOME2) applications will use the GTK-2 theme, which can be tweaked by modifying the `gtk-color-scheme` variable in `gtk-2.0/gtkrc`

```
gtk-color-scheme = "base_color:#efefef\nfg_color:#000000\ntooltip_fg_color:#000000\nselected_bg_color:#688060\nselected_fg_color:#ffffff\ntext_color:#000000\nbg_color:#dfdfdf\ninsensitive_bg_color:#F4F4F2\ntooltip_bg_color:#f5f5b5"
```

## Activating theme changes

If you customise any of the settings above, you will need to reload the theme. The easiest is to use `gnome-tweak` to first change the theme to `Adwaita`, then back to `Adwaita-Tweaked`.

# Implementation Information

## Modifications from original

### index.theme

* Description changes

### Gtk2 theme

Use `axxapy`'s `Adwaita-dark-gtk2` theme as the basis for the Gtk2 dark theme.

  * https://github.com/axxapy/Adwaita-dark-gtk2

This is set up as a submodule, so if you clone this repository, you need to execute:

```
git submodule update --init --recursive
```

#### gtk-2.0/

Most entries in the `gtk-2.0` directory are symlinks to their counterparts in
the `Adwaita-dark-gtk2/gtk-2.0` directory, except one.

##### gtk-2.0/gtkrc

* Add `gtk-color-scheme` variable:

```
gtk-color-scheme = "base_color:#efefef\nfg_color:#000000\ntooltip_fg_color:#000000\nselected_bg_color:#688060\nselected_fg_color:#ffffff\ntext_color:#000000\nbg_color:#dfdfdf\ninsensitive_bg_color:#F4F4F2\ntooltip_bg_color:#f5f5b5"
```

### Gtk3 Theme

#### Additional files in gtk-3.0:

##### Static:

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

##### Generated:

  * `gtk-color-names.css`, `gtk-color-names-dark.css`

    Contains `@define-color` statements for each and every colour that is specified in the original theme (`gtk-contained.css` and `gtk-contained-dark.css`, resp.). Each unique colour gets its own name, e.g. `#cc0000` is defined as `color1`.

  * `gtk-zenburn-colors.css`, `gtk-zenburn-colors-dark.css`

    Contains the colours in the "`names`" files above, expressed as shades of the base theme colors.

