#!perl -I../../lib

# Test Scalar vs Scalar1 functionality

use strict;
use Test::More;
use ReadonlyX;

sub expected
{
    my $line = shift;
    $@ =~ s/\.$//;   # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__ . " line $line\n";
}

use vars qw/$s2 $s4/;
my $m1 = 17;
my $m2 = \$m1;

# Create (4 tests)
eval {Readonly::Scalar  $s2 => ["this", "is", "a", "test", {x => 5}]};
is $@ => '', 'Create a deep reference scalar';
eval {Readonly::Scalar  $s4 => $m2};
is $@ => '', 'Create a deep scalar ref';

# Modify (16 tests)
eval {$s2 = 7};
is $@ => expected(__LINE__-1), 'Modify s2';
eval {$s4 = 7};
is $@ => expected(__LINE__-1), 'Modify s4';

eval {$s2->[2] = "the"};
is $@ => expected(__LINE__-1), 'Deep-modify s2';
is $s2->[2] => 'a', 's2 modification supposed to fail';

eval {$s2->[4]{z} = 42};
like $@ => qr[Attempt to access disallowed key 'z' in a restricted hash], 'Deep-deep modify s2';
ok !exists($s2->[4]{z}), 's2 mod supposed to fail';

eval {$$s4 = 21};
is $@ => expected(__LINE__-1), 'Deep-modify s4 should fail';
is $m1 => 17, 's4 mod should fail';

#
done_testing;
