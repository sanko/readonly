#!perl -I../../lib
# No implicit undef!
use strict;
use Test::More;
use ReadonlyX;

eval q'Readonly::Scalar my $scalar;';
#like $@ => qr[Not enough arguments for Readonly::Scalar],
#    'Readonly::Scalar does not allow implicit undef values';
eval q'Readonly my $scalar;';
#like $@ => qr[Not enough arguments for Readonly::Readonly],
#    'Readonly::Readonly does not allow implicit undef values';
#
done_testing;
