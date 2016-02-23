#!perl -I../../lib
# Verify the Readonly function rejects initialization by assignment
use strict;
use Test::More tests => 9;

use constant ASSIGNMENT_ERR => qr/
    \QInvalid initialization by assignment\E | # added by patch
    \QType of arg 1 to Readonly::Readonly must be one of\E # pre v5.16
/x;

# Find the module (1 test)
BEGIN { use_ok('Readonly'); }

SKIP:
{
    skip 'Readonly $@% syntax is for perl 5.8 or later', 8  unless $] >= 5.008;

eval 'Readonly my $simple = 2;';
like $@ => ASSIGNMENT_ERR, 'Reject scalar initialization by assignment';

eval 'Readonly my @a = (3, 5);';
like $@ => ASSIGNMENT_ERR,
    'Reject array initialization by assignment';

eval 'Readonly my %h = (key => 42);';
like $@ => ASSIGNMENT_ERR,
    'Reject hash initialization by assignment';

eval 'Readonly my %h = {key => 42};';
like $@ => ASSIGNMENT_ERR,
    'Reject hash initialization by assignment to hash ref';

eval 'Readonly my @a;';
is $@ => '', 'Readonly empty array OK';
eval 'Readonly my @a; $a[0] = 2;';
like $@ => qr/Modification of a read-only/,
    'Readonly empty array is read only';

eval 'Readonly my %h;';
is $@ => '', 'Readonly empty hash OK';
eval 'Readonly my %h; $h{key} = "v";';
like $@ => qr/Modification of a read-only/,
    'Readonly empty hash is read only';

}
