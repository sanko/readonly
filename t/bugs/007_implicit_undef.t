#!perl -I../../lib
# Verify the Readonly function accepts implicit undef values
use strict;
use Test::More tests => 3;

sub expected {
    my $line = shift;
    $@ =~ s/\.$//;    # difference between croak and die
    return "Invalid tie at " . __FILE__ . " line $line\n";
}

# Find the module (1 test)
BEGIN { use_ok('Readonly'); }
eval 'Readonly my $simple;';
is $@ => '', 'Simple API allows for implicit undef values';
eval q'Readonly::Scalar my $scalar;';
like $@ => qr[Not enough arguments for Readonly::Scalar],
    'Readonly::Scalar does not allow implicit undef values';
