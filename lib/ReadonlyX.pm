package ReadonlyX;
use 5.008;
use strict;
use warnings;
our $VERSION = "1.04";
BEGIN { *ReadonlyX:: = *Readonly:: }
package          # hide from PAUSE
    Readonly;    # I wish...
use Carp;
use Exporter;
use vars qw/@ISA @EXPORT @EXPORT_OK/;
push @ISA,       'Exporter';
push @EXPORT,    qw/Readonly/;
push @EXPORT_OK, qw/Scalar Array Hash/;
our $VERSION = "1.04"; # Fake
#
sub Array(\@;@);
sub Hash(\%;@);
sub Scalar($;$);
sub Readonly(\[%@$]$);
#
sub Array(\@;@) {
    my $var = $#_ == 0 && defined $_[0] ? $_[0] : $_[1];
    @{$_[0]}
        = ref $var eq 'ARRAY'
        && $#_ == 1
        && ref $var eq 'ARRAY' ? @{$var} : @_[1 .. $#_]
        if $#_ > 0;
    _readonly($_[0]);
}

sub Hash(\%;@) {
    my $var = $#_ == 0 && defined $_[0] ? $_[0] : $_[1];
    my $ref = ref $var;
    Carp::croak 'Odd number of elements in hash assignment'
        unless (@_ % 2 == 1) || $ref eq 'HASH';
    %{$_[0]} = ref $var eq 'HASH' && $#_ == 1 ? %{$var} : @_[1 .. $#_]
        if $#_ > 0;
    _readonly($_[0]);
}

sub Scalar($;$) {
    my $var = $#_ == 0 && defined $_[0] ? $_[0] : $_[1];
    my $ref = ref $var;
    $ref eq 'ARRAY' ? $_[0] = $var : $ref eq 'HASH' ? $_[0]
        = $var : $ref eq 'SCALAR'
        or $ref eq '' ? $_[0] = $var : $ref eq 'REF' ? $_[0] = \$_[1] : 1;
    _readonly($_[0]);
    Internals::SvREADONLY($_[0], 1);
}

sub Readonly(\[%@$]$) {
    my $type = ref $_[0];
    return Scalar(${$_[0]}, defined $_[1] ? $_[1] : ())
        if $type eq 'SCALAR' or $type eq '';
    return Hash(%{$_[0]}, defined $_[1] ? $_[1] : ()) if $type eq 'HASH';
    return Array(@{$_[0]}, defined $_[1] ? $_[1] : []) if $type eq 'ARRAY';
}

sub _readonly {
    my $type = ref $_[0];
    my ($onoff) = $#_ ? $_[1] : 1;
    if ($type eq '') {
        return Internals::SvREADONLY($_[0], $onoff);
    }
    elsif ($type eq 'SCALAR') {
        return Internals::SvREADONLY(${$_[0]}, $onoff);
    }
    elsif ($type eq 'HASH') {
        for my $key (keys %{$_[0]}) {
            _readonly($_[0]->{$key}, $onoff);
            Internals::SvREADONLY($_[0]->{$key}, $onoff);
        }
        return Internals::SvREADONLY(%{$_[0]}, $onoff);
    }
    elsif ($type eq 'ARRAY') {
        for my $index (0 .. $#{$_[0]}) {
            _readonly($_[0]->[$index], $onoff);
            Internals::SvREADONLY($_[0]->[$index], $onoff);
        }
        return Internals::SvREADONLY(@{$_[0]}, $onoff);
    }
    elsif ($type eq 'REF') {
        my $refref = ref ${$_[0]};
        _readonly(${$_[0]}, $onoff);
        return Internals::SvREADONLY(@${$_[0]}, $onoff)
            if $refref eq 'ARRAY';
        return Internals::SvREADONLY(%${$_[0]}, $onoff)
            if $refref eq 'HASH';
        return Internals::SvREADONLY(${$_[0]}, $onoff);
    }
    Carp::carp 'We do not know what to do with ' . $type;
}

sub Clone(\[$@%]) {
    require Storable;
    my $retval = Storable::dclone($_[0]);
    $retval = $$retval if ref $retval eq 'REF';
    my $type = ref $retval;
    _readonly((  $type eq 'SCALAR' || $type eq '' ? $$retval
               : $type eq 'HASH'  ? $retval
               : $type eq 'ARRAY' ? @$retval
               :                    $retval
              ),
              0
    );
    return $type eq 'SCALAR' ?
        $$retval
        : ($type eq 'ARRAY' ?
               wantarray ?
               @$retval
               : $retval
               : ($type eq 'HASH' ? wantarray ? %$retval : $retval : $retval)
        );
}
1;

=head1 NAME

ReadonlyX - Faster facility for creating read-only scalars, arrays, hashes

=head1 Synopsis

    use strict;
    use warnings;
    use ReadonlyX;

    # Read-only scalar
    my $sca1;
    Readonly::Scalar $sca1    => 3.14;
    Readonly::Scalar my $sca2 => time;
    Readonly::Scalar my $sca3 => 'Welcome';
    my $sca4 = time();
    Readonly::Scalar $sca4; # Value is not clobbered

    # Read-only array
    my @arr1;
    Readonly::Array @arr1 => [1 .. 4];

    # or:
    Readonly::Array my @arr2 => (1, 3, 5, 7, 9);

    # Read-only hash
    my %hash1;
    Readonly::Hash %hash1    => (key => 'value', key2 => 'value');
    Readonly::Hash my %hash2 => (key => 'value', key2 => 'value');

    # or:
    Readonly::Hash my %hash3 => {key => 'value', key2 => 'value'};

    # You can use the read-only variables like any regular variables:
    print $sca1;
    my $something = $sca1 + $arr1[2];
    warn 'Blah!' if $hash1{key2};

    # But if you try to modify a value, your program will die:
    $sca2 = 7;           # "Modification of a read-only value attempted"
    push @arr1, 'seven'; # "Modification of a read-only value attempted"
    $arr1[1] = 'nine';   # "Modification of a read-only value attempted"
    delete $hash1{key};  # Attempt to delete readonly key 'key' from a restricted hash

    # Create mutable clones
    Readonly::Scalar $scalar => {qw[this that]};
    # $scalar->{'eh'} = 'foo'; # Modification of a read-only value attempted
    my $scalar_clone = Readonly::Clone $scalar;
    $scalar_clone->{'eh'} = 'foo';
    # $scalar_clone is now {this => 'that', eh => 'foo'};

=head1 Description

This is a near-drop-in replacement for L<Readonly>, the popular facility for
creating non-modifiable variables. This is useful for configuration files,
headers, etc. It can also be useful as a development and debugging tool for
catching updates to variables that should not be changed.

If you really need to have immutable variables in new code, use this instead
of Readonly. You'll thank me later. See the section entitled
L<ReadonlyX vs. Readonly> for more.

=head1 Functions

All of these functions can be imported into your package by name.

=head2 Readonly::Scalar

    Readonly::Scalar $pi      => 3.14;
    Readonly::Scalar my $aref => [qw[this that]]; # list ref
    Readonly::Scalar my $href => {qw[this that]}; # hash ref

Creates a non-modifiable scalar and assigns a value of to it. Thereafter, its
value may not be changed. Any attempt to modify the value will cause your
program to die.

If the given value is a reference to a scalar, array, or hash, then this
function will mark the scalar, array, or hash it points to as being readonly
as well, and it will recursively traverse the structure, marking the whole
thing as readonly.

If the variable is already readonly, the program will die with an error about
reassigning readonly variables.

=head2 Readonly::Array

    Readonly::Array @arr1    => [1 .. 4];
    Readonly::Array my @arr2 => (1, 3, 5, 7, 9);

Creates a non-modifiable array and assigns the specified list of values to it.
Thereafter, none of its values may be changed; the array may not be lengthened
or shortened. Any attempt to do so will cause your program to die.

If any of the values passed is a reference to a scalar, array, or hash, then
this function will mark the scalar, array, or hash it points to as being
Readonly as well, and it will recursively traverse the structure, marking the
whole thing as Readonly.

If the variable is already readonly, the program will die with an error about
reassigning readonly variables.

=head2 Readonly::Hash

    Readonly::Hash %h => (key => 'value', key2 => 'value');
    Readonly::Hash %h => {key => 'value', key2 => 'value'};

Creates a non-modifiable hash and assigns the specified keys and values to it.
Thereafter, its keys or values may not be changed. Any attempt to do so will
cause your program to die.

A list of keys and values may be specified (with parentheses in the synopsis
above), or a hash reference may be specified (curly braces in the synopsis
above). If a list is specified, it must have an even number of elements, or
the function will die.

If any of the values is a reference to a scalar, array, or hash, then this
function will mark the scalar, array, or hash it points to as being Readonly
as well, and it will recursively traverse the structure, marking the whole
thing as Readonly.

If the variable is already readonly, the program will die with an error about
reassigning readonly variables.

=head2 Readonly::Clone

    my $scalar_clone = Readonly::Clone $scalar;

When cloning using L<Storable> or L<Clone> you will notice that the value
stays readonly, which is correct. If you want to clone the value without
copying the readonly flag, use this.

    Readonly::Scalar my $scalar => {qw[this that]};
    # $scalar->{'eh'} = 'foo'; # Modification of a read-only value attempted
    my $scalar_clone = Readonly::Clone $scalar;
    $scalar_clone->{'eh'} = 'foo';
    # $scalar_clone is now {this => 'that', eh => 'foo'};

In this example, the new variable (C<$scalar_clone>) is a mutable clone of the
original C<$scalar>. You can change it like any other variable.

=head1 Examples

Here are a few very simple examples again to get you started:

=head2 Scalars

A plain old read-only value:

    Readonly::Scalar $a => "A string value";

The value need not be a compile-time constant:

    Readonly::Scalar $a => $computed_value;

Need an undef constant? Okay:

    Readonly::Scalar $a;

=head2 Arrays/Lists

A read-only array:

    Readonly::Array @a => (1, 2, 3, 4);

The parentheses are optional:

    Readonly::Array @a => 1, 2, 3, 4;

You can use Perl's built-in array quoting syntax:

    Readonly::Array @a => qw[1 2 3 4];

You can initialize a read-only array from a variable one:

    Readonly::Array @a => @computed_values;

A read-only array can be empty, too:

    Readonly::Array @a => ();
    # or
    Readonly::Array @a;

=head2 Hashes

Typical usage:

    Readonly::Hash %a => (key1 => 'value1', key2 => 'value2');
    # or
    Readonly::Hash %a => {key1 => 'value1', key2 => 'value2'};

A read-only hash can be initialized from a variable one:

    Readonly::Hash %a => %computed_values;

A read-only hash can be empty:

    Readonly::Hash %a => ();
    # or
    Readonly::Hash %a;

If you pass an odd number of values, the program will die:

    Readonly::Hash my %a => (key1 => 'value1', "value2");
    # This dies with "Odd number of elements in hash assignment"

=head1 ReadonlyX vs. Readonly

The original Readonly module was written nearly twenty years ago when the
built-in capability to lock variables didn't exist in perl's core. The
original author came up with the amazingly brilliant idea to use the new (at
the time) C<tie(...)> construct. It worked amazingly well! But it wasn't long
before the speed penalty of tied varibles became embarrassingly obvious. Check
any review of Readonly written before 2013; the main complaint was how slow it
was and the benchmarks proved it.

In an equally brilliant move to work around tie, Readonly::XS was released for
perl 5.8.9 and above. This bypassed C<tie(...)> for basic scalars which made a
huge difference.

During all this, two very distinct APIs were also designed and supported by
Readonly. One for (then) modern perl and one written for perl 5.6. To make
this happen, time consuming eval operations were required and the codebase
grew so complex that fixing bugs was nearly impossible. Readonly was three
different modules all with different sets of quirks and bugs to fix depending
on what version of perl and what other modules you had installed. It was a
mess.

So, after the original author abandoned both Readonly and Readonly::XS, as
bugs were found, they went unfixed. The combination of speed and lack of
development spawned several similar modules which usually did a better job but
none were a total drop-in replacement.

Until now.

ReadonlyX is the best of recent versions of Readonly without the old API and
without the speed penalty of C<tie(...)>. It's what I'd like to do with
Readonly if resolving bugs in it wouldn't break 16 years of code out there in
Darkpan.

In short, unlike Readonly, ReadonlyX...

=over

=item ...does not use slow C<tie(...)> magic or eval. There shouldn't be a
        speed penalty after making the structure immutable. See the
        L<Benchmarks> section below

=item ...does not strive to work on perl versions I can't even find a working
        build of to test against

=item ...has a single, clean API! What do all of these different forms of the
        original Readonly API do?

    use Readonly;
    Readonly  my @array1        => [2];
    Readonly \my @array2        => [2];
    Readonly::Array  my @array3 => [2];
    Readonly::Array1 my @array4 => [2];

Be careful because they all behave very differently. Even your version of perl
and the contents of the list changes how they work. Give up? Yeah, me too.
Bonus: Guess which one doesn't actually make the list items read only.

=item ...does the right thing when it comes to deep vs. shallow structures

=item ...allows implicit undef values for scalars (Readonly inconsistantly
        allows this for hashes and arrays but not scalars)

=item ...a lot more I can't think of right now but will add when they come to
        me

=item ...is around 100 lines instead of 460ish so maintaining it will be a
        breeze

=item ...doesn't clobber predefined variables when making them readonly

Using Readonly, this:

    my @array = qw[very important stuff];
    Readonly::Array @array;
    print "@array";

...wouldn't print anything. I consider it a bug but I'm not sure why it was
designed this way originally. With ReadonlyX, you won't lose your
C<'very important stuff'>.

Note that this is an incompatible change! If you attempt to do this and then
switch to plain 'ol Readonly, your code will not work.

=back

=head1 Benchmarks

Don't believe Readonly is slow? Here's the result of basic benchmarking:

    Hash Benchmark: timing 5000000 iterations of const, normal, readonly, readonlyx...
         const:  3 wallclock secs ( 2.73 usr +  0.02 sys =  2.75 CPU) @ 1818181.82/s (n=5000000)
        normal:  3 wallclock secs ( 3.02 usr + -0.02 sys =  3.00 CPU) @ 1666666.67/s (n=5000000)
      readonly: 47 wallclock secs (40.64 usr +  0.03 sys = 40.67 CPU) @ 122931.67/s (n=5000000)
     readonlyx:  4 wallclock secs ( 3.22 usr + -0.01 sys =  3.20 CPU) @ 1560549.31/s (n=5000000)
    Array Benchmark: timing 5000000 iterations of const, normal, readonly, readonlyx...
         const:  3 wallclock secs ( 2.19 usr +  0.03 sys =  2.22 CPU) @ 2253267.24/s (n=5000000)
        normal:  1 wallclock secs ( 1.44 usr +  0.00 sys =  1.44 CPU) @ 3474635.16/s (n=5000000)
      readonly: 36 wallclock secs (32.52 usr +  0.13 sys = 32.64 CPU) @ 153181.58/s (n=5000000)
     readonlyx:  1 wallclock secs ( 1.12 usr + -0.02 sys =  1.11 CPU) @ 4512635.38/s (n=5000000)
    Scalar Benchmark: timing 5000000 iterations of const, normal, readonly, readonlyx...
         const:  1 wallclock secs ( 1.14 usr + -0.02 sys =  1.12 CPU) @ 4448398.58/s (n=5000000)
        normal:  1 wallclock secs ( 0.99 usr +  0.02 sys =  1.00 CPU) @ 4995005.00/s (n=5000000)
      readonly:  1 wallclock secs ( 1.25 usr +  0.00 sys =  1.25 CPU) @ 4000000.00/s (n=5000000)
     readonlyx:  2 wallclock secs ( 1.20 usr +  0.00 sys =  1.20 CPU) @ 4156275.98/s (n=5000000)

Find the script to run them yourself in C<eg/benchmark.pl>.

=head1 Requirements

There are no non-core requirements.

=head1 Bug Reports

If email is better for you, L<my address is mentioned below|/"Author"> but I
would rather have bugs sent through the issue tracker found at
http://github.com/sanko/readonly/issues.

ReadonlyX can be found is the branch of Readonly found here:
https://github.com/sanko/readonly/tree/ReadonlyX

=head1 Author

Sanko Robinson <sanko@cpan.org> - http://sankorobinson.com/

CPAN ID: SANKO

=head1 License and Legal

Copyright (C) 2016 by Sanko Robinson <sanko@cpan.org>

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
