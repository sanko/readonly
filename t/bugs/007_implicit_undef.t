#!perl -I../../lib
# No implicit undef!
use strict;
use Test::More;
use ReadonlyX;
#
Readonly::Scalar my $scalar;
is_deeply [$scalar], [undef], 'Readonly::Scalar allows implicit undef values';
#
Readonly::Hash my %hash;
is_deeply [%hash], [], 'Readonly::Hash allows implicit undef values';
#
Readonly::Array my @array;
is_deeply [@array], [], 'Readonly::Array allows implicit undef values';
#
eval q'Readonly my $scalar;';
like $@ => qr[Not enough arguments for Readonly::Readonly],
    'Readonly::Readonly does not allow implicit undef values';
done_testing;
