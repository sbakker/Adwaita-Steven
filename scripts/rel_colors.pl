#!/usr/bin/perl

use strict;

my $comments = 0;

if (@ARGV && $ARGV[0] eq '-c') {
    shift @ARGV;
    $comments++;
}

my $distance_threshold = 1;

my %colors;
read_colors(\%colors);
rgb_to_hex(\%colors);
rel_colors(\%colors);

sub read_colors {
    my $colors = shift;

    while (<>) {
        if (/^\s*\@define-color\s+([\w\-]+)\s+(.*)$/) {
            $colors->{$1} = $2;
        }
    }
}


sub rel_colors {
    my $colors = shift;

    my $base_colors = extract_colors($colors,
            qw( 
                base_color
                bg_color
                tooltip_bg_color
                selected_bg_color
                text_color
                fg_color
                tooltip_fg_color
                selected_fg_color
                theme_base_color
                theme_bg_color
                theme_selected_bg_color
                theme_text_color
                theme_fg_color
                theme_selected_fg_color
            )
        );

    # Dump the default set of base colors.
    print "/*\n";
    for my $name (sort keys %$base_colors) {
        print "  \@define-color $name $$base_colors{$name};\n";
    }
    print "*/\n\n";

    # Some colors should not be touched...
    delete $colors->{link_color};

    # For each color, find the best fit relative to the "base_colors",
    # i.e. for which base color a "shade" would come closest.
    # Then, express the color as a shade of the particular base color.

    for my $name (sort keys %$colors) {
        if ($colors->{$name} =~ /^(#[\da-f]{3,6})(.*?)$/) {
            my ($org_color, $tail) = ($1, $2);
            if ($comments) {
                print "/* $name\n";
                printf "  \@define-color %s %s%s\n", $name, $org_color, $tail;
            }
            my ($delta, $base, $shade) = best_fit($org_color, $base_colors);
            print " */\n" if $comments;

            my $color = sprintf("shade(\@%s, %0.2f)", $base, $shade);
            if ($delta >= $distance_threshold) {
                if ($comments) {
                    print "/* NO OVERRIDE\n" if $delta >= $distance_threshold;
                    print "\@define-color $name $color$tail\n";
                    print " */\n" if $delta >= $distance_threshold;
                }
            }
            else {
                print "\@define-color $name $color$tail\n";
            }
        }
        else {
            print "\@define-color $name $$colors{$name}\n";
        }
    }
}

sub best_fit {
    my ($color, $base_colors) = @_;
    my @results;
    while (my ($base_name, $base_val) = each %$base_colors) {
        my ($shade_factor, $fit, $factors) = diff_color($base_val, $color);
        push @results, [$fit, $base_name, $shade_factor, $factors];
    }
    @results = sort { $$a[0] <=> $$b[0] } @results;
    if ($comments) {
        for my $r (@results) {
            printf " * $color -> d=%0.3f s=%0.2f b=%s", $$r[0], $$r[2], $$r[1];
            print " ;";
            for my $f (@{$$r[3]}) {
                printf " %0.2f", $f;
            }
            print "\n";
        }
    }
    return @{$results[0]};
}

sub diff_color {
    my ($rgb1, $rgb2) = @_;

    my ($r1, $g1, $b1) = map { length($_) == 1 ? hex("$_$_") : hex($_) }
                                $rgb1 =~ m/^#(.{1,2})(.{1,2})(.{1,2})$/;
    my ($r2, $g2, $b2) = map { length($_) == 1 ? hex("$_$_") : hex($_) }
                                $rgb2 =~ m/^#(.{1,2})(.{1,2})(.{1,2})$/;

    # Calculate fractional differences for R,G,B.
    my $r_factor = $r1 ? $r2/$r1 : 0;
    my $g_factor = $g1 ? $g2/$g1 : 0;
    my $b_factor = $b1 ? $b2/$b1 : 0;

    # Calculate the average fractional difference.
    my $avg_factor = ($r_factor + $g_factor + $b_factor) / 3;

    if ($avg_factor == 0) {
        return ($avg_factor, '255', [$r_factor, $g_factor, $b_factor]);
    }

    # Apply the average fractional difference.
    $r2 *= $avg_factor;
    $g2 *= $avg_factor;
    $b2 *= $avg_factor;

    # We now have "rgb2" corrected in the direction of $rgb1.
    # Now we need to calculate the distance.
    # Calculating color differences in RGB space is not so
    # straightforward. Using Euclidian distance does not match
    # human experience.
    #
    # See: http://www.compuphase.com/cmetric.htm
    #
    # Here, I use the algorithm from that page.

    my $rmean = ($r1 + $r2) / 2;
    #my $r = ($r1 - $r2)**2;
    #my $g = ($g1 - $g2)**2;
    #my $b = ($b1 - $b2)**2;
    my $r = ($avg_factor - $r_factor)**2;
    my $g = ($avg_factor - $g_factor)**2;
    my $b = ($avg_factor - $b_factor)**2;

    my $xdistance = sqrt(($r + $g + $b) / 3);
    my $distance = sqrt(
        ( ( (512+$rmean) * $r ) / 256 ) 
        + 4*$g 
        + ( ( abs(767-$rmean) * $b ) / 256 )
    );
    return ($avg_factor, $distance, [$r_factor, $g_factor, $b_factor]);
}

sub extract_colors {
    my ($colors, @color_names) = @_;
    my %extract;

    for my $name (@color_names) {
        if ($colors->{$name} =~ /^(#[\da-f]{3,6})/i) {
            $extract{$name} = $1;
            delete $colors->{$name};
        }
    }
    return \%extract;
}


sub rgb_to_hex {
    my $colors = shift;

    for my $name (keys %$colors) {
        $colors->{$name} =~ s/white/#ffffff/g;
        $colors->{$name} =~ s/black/#000000/g;
        $colors->{$name} =~
            s{ rgb \s* \( \s*
               (\d+) \s* , \s*
               (\d+) \s* , \s*
               (\d+) \s* \)
            }{sprintf("#%02x%02x%02x", $1, $2, $3)}gex;
    }
}
