#!perl -I../../lib
# Verify the Readonly function accepts implicit undef values
use strict;
use Test::More;
use Readonly;

sub expected {
    my $line = shift;
    $@ =~ s/\.$//;    # difference between croak and die
    return "Invalid tie at " . __FILE__ . " line $line\n";
}
SKIP: {
    skip 'Readonly $@% syntax is for perl 5.8 or later', 1 unless $] >= 5.008;
    eval 'Readonly my $simple;';
    is $@ => '', 'Simple API allows for implicit undef values';
}
eval q'Readonly::Scalar my $scalar;';
like $@ => qr[Not enough arguments for Readonly::Scalar],
    'Readonly::Scalar does not allow implicit undef values';
#
done_testing;
