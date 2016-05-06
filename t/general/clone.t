#!perl -I../../lib

# Readonly clone tests

use strict;
use Test::More tests => 6;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

Readonly::Scalar my $scalar => 13;
Readonly::Array my @array => (1, 2, 3);
Readonly::Hash my %hash => (foo => 'bar');
Readonly::Array my @deep_array => (1, \@array);
Readonly::Hash my %deep_hash => (foo => \@array);

my $scalar_clone = Readonly::Clone $scalar;
$scalar_clone++;
is $scalar_clone, 14;

my @array_clone = Readonly::Clone @array;
$array_clone[1] = 4;
is $array_clone[1], 4;

my %hash_clone = Readonly::Clone %hash;
$hash_clone{foo} = 'baz';
is $hash_clone{foo}, 'baz';

my @deep_array_clone = Readonly::Clone @deep_array;
$deep_array_clone[1]->[2] = 4;
is $deep_array_clone[1]->[2], 4;

my %deep_hash_clone = Readonly::Clone %deep_hash;
$deep_hash_clone{foo}->[1] = 4;
is $deep_hash_clone{foo}->[1], 4;
