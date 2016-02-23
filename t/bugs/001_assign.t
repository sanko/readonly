#!perl -I../../lib
# Verify the Readonly function rejects initialization by assignment
use strict;
use Test::More tests => 9;

use constant ASSIGNMENT_ERR => qr/Invalid initialization by assignment/;

# Find the module (1 test)
BEGIN { use_ok('Readonly'); }

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

