#!perl -I../../lib
# Readonly array tests
use strict;
use warnings;
use Test::More;
use ReadonlyX;

sub expected {
    my $line = shift;
    $@ =~ s/\.$//;    # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__
        . " line $line\n";
}
use vars qw/@a1 @a2/;
my @ma1;

# creation (3 tests)
eval 'Readonly::Array @a1;';
is $@ => '', 'Create empty global array';
eval 'Readonly::Array @ma1 => ();';
is $@ => '', 'Create empty lexical array';
eval 'Readonly::Array @a2 => (1,2,3,4,5);';
is $@ => '', 'Create global array';

# fetching (3 tests)
ok !defined($a1[0]), 'Fetch global';
is $a2[0]  => 1, 'Fetch global';
is $a2[-1] => 5, 'Fetch global';

# fetch size (3 tests)
is scalar(@a1)  => 0, 'Global size (zero)';
is scalar(@ma1) => 0, 'Lexical size (zero)';
is $#a2         => 4, 'Global last element (nonzero)';

# store (2 tests)
TODO: {
    local $TODO
        = 'perl *could* mess with some readonly vars before 5.12 stable';
    eval { $ma1[0] = 5; };
    is $@ => expected(__LINE__- 1), 'Lexical store';
}
eval { $a2[3] = 4; };
is $@ => expected(__LINE__- 1), 'Global store';

# storesize (1 test)
eval { $#a1 = 15; };
is $@ => expected(__LINE__- 1), 'Change size';

# extend (1 test)
eval { $a1[77] = 88; };
is $@ => expected(__LINE__- 1), 'Extend';

# exists (2 tests)
SKIP: {
    skip "Can't do exists on array until Perl 5.6", 2 if $] < 5.006;
    eval 'ok(exists $a2[4], "Global exists")';
    eval 'ok(!exists $ma1[4], "Lexical exists")';
}

# clear (1 test)
eval { @a1 = (); };
is $@ => expected(__LINE__- 1), 'clear';
TODO: {
    local $TODO
        = 'perl *could* mess with some readonly vars before 5.12 stable';

    # push (1 test)
    eval { push @ma1, -1; };
    is $@ => expected(__LINE__- 1), 'push';
}

# unshift (1 test)
eval { unshift @a2, -1; };
is $@ => expected(__LINE__- 1), 'unshift';

# pop (1 test)
eval { pop(@a2); };
is $@ => expected(__LINE__- 1), 'pop';

# shift (1 test)
eval { shift(@a2); };
is $@ => expected(__LINE__- 1), 'shift';
TODO: {
    local $TODO = "Can't test splice on readonly array; bug in perl";

    # splice (1 test)
    eval { splice @a2, 0, 1; };
    is $@ => expected(__LINE__- 1), 'splice';
}
done_testing;
