# Make Adwaita Great Again!

_... or at least tweakable._

The Adwaita theme is now the default theme for Gnome3 and is fine for most uses. However, I don't agree with all color choices, and would like to add a bit of Zenburn to it (mostly green for highlighting, rather than blue).

Gnome2 and Gtk2 used to support setting the `gtk-color-scheme` variable (in `gtkrc`), that allowed color tweaks to stock themes, by changing a limited set of base colors.

Since Gtk3 moved to CSS, this is no longer possible. To make any tweaks, one has to copy the theme files to one's `~/.themes` directory, and modify the colors in the CSS files. That in itself wouldn't be so bad if only the theme were expressed in shades of the base colors. That's not the case, unfortunately. The CSS files of the Adwaita dark theme alone contain 110 unique colors (the light theme 102), each one specified as a literal RGB value.

Of course, what we get in our distributed themes is a compiled version of the Adwaita sources, which I'm sure are full of macros and handy tools. The thing is, I don't want to set up a complete tool chain just to tweak a few colors.

So, I came up with another approach:

 * Define a set of base colors for the theme.
 * Express all other colors as shades of these base colors.

With that done, a tweak of a single base color *should* modify related colors in a way that is hopefully not too jarring.

All I can say is, "it works for me", but YMMV, and I'm fairly sure the whole thing breaks down when you make extreme color modifications.

So, below I'll outline what I did, along with instructions on reproducing this.

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

Run the `make_theme.sh` script:

```
./make_theme.sh
```

See the script itself for more details.
