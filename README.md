# Make Adwaita Great Again (COSMIC Edition)

***NOTE: These tweaks are optimised for dark themes only ***

The [COSMIC desktop environment](https://system76.com/cosmic) allows the
kind of colour tweaks that was the whole reason for **Adwaita-Steven** to
exist.

This means that this particular branch no longer needs to play fast and
loose with GTK settings and themes. The COSMIC desktop settings allow you
to fine-tune colours quite nicely.

The _only_ thing that is missing for me is the tweaking of the
[Evolution mail](https://wiki.gnome.org/Apps/Evolution)
application. In dark mode, unread mail is less distinguishable than in
light mode. Bold white text on a dark background stands out less than bold
black text on a white background. Go figure. Hence, it's useful to use a
different background colour for unread mail.

That is what this theme does: it sets a few custom CSS rules for
the `MessageList` and just inherits the rest from `adw-gtk3-dark`.

# Requirements

## gnome-tweaks

In order to select and activate the tweaked theme, you need the `gnome-tweaks` tool installed.

 * Fedora/RHEL/CentOS: `sudo dnf install gnome-tweaks`
 * Debian/Ubuntu: `sudo apt install gnome-tweaks`

# Installation

## Clone the repository

```
mkdir -p ~/.themes
cd ~/.themes
git clone https://github.com/sbakker/Adwaita-Steven.git Adwaita-Cosmic-Tweaked
cd Adwaita-Cosmic-Tweaked
# Needed for pulling in `axxapy`'s `Adwaita-dark-gtk2` theme.
git submodule update --init --recursive
```

## Activating the theme

 * Start `gnome-tweaks`.
 * In the *Appearance* tab, under *Styles*, the dropdown menu for *Legacy Applications* should now contain *Adwaita-Cosmic-Tweaked*.
 * Select *Adwaita-Cosmic-Tweaked*.

## Customising the theme

### GTK-3


### GTK-2

Legacy (GNOME2) applications will use the GTK-2 theme, which can be tweaked by modifying the `gtk-color-scheme` variable in `gtk-2.0/gtkrc`

```
gtk-color-scheme = "base_color:#efefef\nfg_color:#000000\ntooltip_fg_color:#000000\nselected_bg_color:#688060\nselected_fg_color:#ffffff\ntext_color:#000000\nbg_color:#dfdfdf\ninsensitive_bg_color:#F4F4F2\ntooltip_bg_color:#f5f5b5"
```

## Activating theme changes

If you customise any of the settings above, you will need to reload the theme. The easiest is to use `gnome-tweak` to first change the theme to `adw-gtk3-dark`, then back to `Adwaita-Cosmic-Tweaked`.

# Implementation Information

## Gtk2 theme

Use `axxapy`'s `Adwaita-dark-gtk2` theme as the basis for the Gtk2 dark theme.

  * https://github.com/axxapy/Adwaita-dark-gtk2

This is set up as a submodule, so if you clone this repository, you need to execute:

```
git submodule update --init --recursive
```

### gtk-2.0/

Most entries in the `gtk-2.0` directory are symlinks to their counterparts in
the `Adwaita-dark-gtk2/gtk-2.0` directory, except one.

#### gtk-2.0/gtkrc

* Add `gtk-color-scheme` variable:

```
gtk-color-scheme = "base_color:#efefef\nfg_color:#000000\ntooltip_fg_color:#000000\nselected_bg_color:#688060\nselected_fg_color:#ffffff\ntext_color:#000000\nbg_color:#dfdfdf\ninsensitive_bg_color:#F4F4F2\ntooltip_bg_color:#f5f5b5"
```

## Gtk3 Theme

The `gtk-3.0/gtk.css` file is a symlink to `gtk-3.0/gtk-dark.css`.

The `gtk-3.0/gtk-dark.css` first imports
`/usr/share/themes/adw-gtk3-dark/gtk-3.0/gtk.css`
and then `gtk-overrides-dark.css`, which contains the custom
colour tweaks.


The `gtk-3.0/gtk.css` file is a symlink to `gtk-3.0/gtk-dark.css`.

The `gtk-3.0/gtk-dark.css` first imports
`/usr/share/themes/adw-gtk3-dark/gtk-3.0/gtk.css`
and then `gtk-overrides-dark.css`, which contains the custom
colour tweaks.

## Gtk4 Theme

The `gtk-4.0/gtk.css` file is a symlink to `gtk-4.0/gtk-dark.css`.

The `gtk-4.0/gtk-dark.css` simply imports
`/usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk.css`.
