#!perl -I../../lib
# Verify partial clones of Readonly vars are mutable
use strict;
use Test::More;
use ReadonlyX;
use Test::Fatal;
#
Readonly::Scalar our $MAP => {'record' => {id    => 1,
                                           title => 'Record',
                              }
};
my $map_partial_copy = Readonly::Clone $MAP->{record};
is exception {
    $map_partial_copy->{id} = 42;
}, undef, 'create mutalbe copy';
#
is $map_partial_copy->{id}, 42, 'mutable copy is... well, mutable';
#
done_testing;
