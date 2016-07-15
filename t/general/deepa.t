#!perl -I../../lib
# Test Array vs Array1 functionality
use strict;
use Test::More;
use ReadonlyX;

sub expected {
    my $line = shift;
    $@ =~ s/\.$//;    # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__
        . " line $line\n";
}
use vars qw/@a1 /;
my $m1 = 17;

# Create (2 tests)
eval { Readonly::Array @a1 => (\$m1, {x => 5, z => [1, 2, 3]}) };
is $@ => '', 'Create a deep reference array';

# Modify (10 tests)
eval { $a1[0] = 7; };
is $@ => expected(__LINE__- 1), 'Modify a1';
eval { ${$a1[0]} = "the"; };
is $@ => expected(__LINE__- 1), 'Deep-modify a1';
is $m1 => 17, 'a1 unchanged';
eval { $a1[1]{z}[1] = 42; };
is $@ => expected(__LINE__- 1), 'Deep-deep modify a1';
is $a1[1]{z}[1] => 2, 'a1 unchanged';
#
done_testing;
