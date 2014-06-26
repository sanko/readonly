#!perl -I../../lib
# Readonly reassignment-prevention tests
use strict;
use Test::More tests => 22;

# Find the module (1 test)
BEGIN { use_ok('Readonly'); }
use vars qw($s1 @a1 %h1 $s2 @a2 %h2);
Readonly $s1 => 'a scalar value';
Readonly @a1 => 'an', 'array', 'value';
Readonly %h1 => {a => 'hash', of => 'things'};
my $err = qr/^Attempt to reassign/;

# Reassign scalar
eval { Readonly $s1 => "a second scalar value" };
ok defined $@, 'Readonly reassign die';
is $s1 => 'a scalar value', 'Readonly reassign no effect';

# Reassign array
eval { Readonly @a1 => "another", "array" };
like $@ => $err, 'Readonly reassign die';
ok eq_array(\@a1, [qw[an array value]]) =>
    'Readonly reassign no effect';

# Reassign hash
eval { Readonly %h1 => "another", "hash" };
like $@ => $err, 'Readonly reassign die';
ok eq_hash(\%h1, {a => 'hash', of => 'things'}) =>
    'Readonly reassign no effect';

# Now use the naked Readonly function
SKIP:
{   skip 'Readonly \\ syntax is for perls earlier than 5.8', 7 if $] >= 5.008;
    eval q{
		Readonly \$s2 => 'another scalar value';
		Readonly \@a2 => 'another', 'array', 'value';
		Readonly \%h2 => {another => 'hash', of => 'things'};
	};

    # Reassign scalar
    eval q{Readonly \$s2 => "something bad!"};
    like $@ => $err, 'Readonly Scalar reassign die';
    is $s2 => 'another scalar value', 'Readonly Scalar reassign no effect';

    # Reassign array
    eval q{Readonly \@a2 => "something", "bad", "!"};
    like $@ => $err, 'Readonly Array reassign die';
    ok eq_array(\@a2, [qw[another array value]]) =>
        'Readonly Array reassign no effect';

    # Reassign hash
    eval q{Readonly \%h2 => {another => "bad", hash => "!"}};
    like $@ => $err, 'Readonly Hash reassign die';
    ok eq_hash(\%h2, {another => 'hash', of => 'things'}) =>
        'Readonly Hash reassign no effect';

    # Reassign real constant
    eval q{Readonly \"scalar" => "vector"};
    like $@ =>
        qr/^Modification of a read-only value attempted at \(eval \d+\),? line 1/,
        'Reassign indirect via ref';
}
SKIP:
{   skip 'Readonly $@% syntax is for perl 5.8 or later', 6 unless $] >= 5.008;
    eval q{
		Readonly $s2 => 'another scalar value';
		Readonly @a2 => 'another', 'array', 'value';
		Readonly %h2 => {another => 'hash', of => 'things'};
	};

    # Reassign scalar
    eval q{Readonly $s2 => "something bad!"};
    like $@ => $err, 'Readonly Scalar reassign die';
    is $s2 => 'another scalar value', 'Readonly Scalar reassign no effect';

    # Reassign array
    eval q{Readonly @a2 => "something", "bad", "!"};
    like $@ => $err, 'Readonly Array reassign die';
    ok eq_array(\@a2, [qw[another array value]]) =>
        'Readonly Array reassign no effect';

    # Reassign hash
    eval q{Readonly %h2 => {another => "bad", hash => "!"}};
    like $@ => $err, 'Readonly Hash reassign die';
    ok eq_hash(\%h2, {another => 'hash', of => 'things'}) =>
        'Readonly Hash reassign no effect';
}

# Reassign real constants
eval q{Readonly "hello" => "goodbye"};
ok defined $@, 'Reassign real string';
eval q{Readonly 6 => 13};
ok defined $@, 'Reassign real number';
