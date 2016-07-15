#!perl -I../../lib

# Test Hash vs Hash1 functionality

use strict;
use Test::More;
use Readonly;

sub expected
{
    my $line = shift;
    $@ =~ s/\.$//;   # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__ . " line $line\n";
}

use vars qw/%h1 /;
my $m1 = 17;

# Create (2 tests)
eval {Readonly::Hash  %h1 => (key1 => \$m1, key2 => {x => 5, z => [1, 2, 3]})};
is $@ => '', 'Create a deep reference array';

# Modify (10 tests)
eval {$h1{key1} = 7};
is $@ => expected(__LINE__-1), 'Modify h1';

eval {${$h1{key1}} = "the"};
is $@ => expected(__LINE__-1), 'Deep-modify h1';
is $m1 => 17, 'h1 unchanged';

eval {$h1{key2}{z}[1] = 42};
is $@ => expected(__LINE__-1), 'Deep-deep modify h1';
is $h1{key2}{z}[1] => 2, 'h1 unchanged';

#
done_testing;
