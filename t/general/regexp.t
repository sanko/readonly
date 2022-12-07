#!perl -I../../lib

# Readonly regexp tests

use strict;
use Test::More;
use ReadonlyX;

sub expected
{
    my $line = shift;
    $@ =~ s/\.$//;   # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__ . " line $line\n";
}

use vars qw/$s1/;
my $ms1;

# creation (2 tests)
eval {Readonly::Scalar $s1 => qr/13/};
is $@ => '', 'Create a global regexp';
eval {Readonly::Scalar $ms1 => qr/31/};
is $@ => '', 'Create a lexical regexp';

# fetching (2 tests)
is $s1  => qr/13/, 'Fetch global';
is $ms1 => qr/31/, 'Fetch lexical';

# storing (2 tests)
eval {$s1 = qr/7/};
is $@ => expected(__LINE__-1), 'Error setting global';
is $s1 => qr/13/, 'Readonly global value unchanged';
#
done_testing;
