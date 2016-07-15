#!perl -I../../lib
use strict;
use Test::More;
#
use_ok('ReadonlyX', qw/Readonly Scalar Array Hash/);
#
can_ok 'main', 'Readonly';
can_ok 'main', 'Scalar';
can_ok 'main', 'Array';
can_ok 'main', 'Hash';
#
done_testing;
