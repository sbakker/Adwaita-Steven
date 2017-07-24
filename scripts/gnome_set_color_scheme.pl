#!/usr/bin/perl

use strict;

my $color_scheme = q{
base_color:#efefef;
bg_color:#dfdfdf;
tooltip_bg_color:#f5f5b5;
selected_bg_color:#688060;
text_color:#000000;
fg_color:#000000;
tooltip_fg_color:#000000;
selected_fg_color:#ffffff;
};

my $scheme = join('', split(/\n/, $color_scheme));

system(qw(gsettings set org.gnome.desktop.interface gtk-color-scheme),
        $scheme);
