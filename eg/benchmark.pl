#!/usr/bin/perl
# Very simple benchmark script to show how slow Readonly.pm is,
# and how Readonly::XS solves the problem.
use strict;
use lib '../lib';
use Readonly;
use Benchmark;
use vars qw/$feedme/;
#
# use constant
#
use constant CONST_LINCOLN => 'Fourscore and seven years ago...';

sub const {
    $feedme = CONST_LINCOLN;
}
#
# literal constant
#
sub literal {
    $feedme = 'Fourscore and seven years ago...';
}
#
# typeglob constant
#
use vars qw/$glob_lincoln/;
*glob_lincoln = \'Fourscore and seven years ago...';

sub tglob {
    $feedme = $glob_lincoln;
}
#
# Normal perl read/write scalar
#
use vars qw/$norm_lincoln/;
$norm_lincoln = 'Fourscore and seven years ago...';

sub normal {
    $feedme = $norm_lincoln;
}
#
# Readonly.pm with verbose API
#
use vars qw/$ro_lincoln/;
Readonly::Scalar $ro_lincoln => 'Fourscore and seven years ago...';

sub ro {
    $feedme = $ro_lincoln;
}
#
# Readonly.pm with simple API
#
use vars qw/$ro_simple_lincoln/;
Readonly $ro_simple_lincoln => 'Fourscore and seven years ago...';

sub ro_simple {
    $feedme = $ro_simple_lincoln;
}
#
# Readonly.pm w/o Readonly::XS
#
use vars qw/$rotie_lincoln/;
{
    local $Readonly::XSokay = 0;    # disable XS
    Readonly::Scalar $rotie_lincoln => 'Fourscore and seven years ago...';
}

sub rotie {
    $feedme = $rotie_lincoln;
}
my $code = {const     => \&const,
            literal   => \&literal,
            tglob     => \&tglob,
            normal    => \&normal,
            ro        => \&ro,
            ro_simple => \&ro_simple,
            rotie     => \&rotie,
};
unless ($Readonly::XSokay) {
    print "Readonly::XS module not found; skipping that test.\n";
    delete $code->{roxs};
}
timethese(2_000_000, $code);
