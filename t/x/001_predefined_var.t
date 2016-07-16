#!perl -I../../lib
# Verify we don't clobber content of pre-defined variables w/o new value
use strict;
use Test::More;
use ReadonlyX;
use Test::Fatal;
#
{
    my $scalar = 'test';
    Readonly::Scalar $scalar;
    is $scalar, 'test', 'predefined scalar is not clobbered';
}
{
    my $scalar = 'test';
    Readonly::Scalar $scalar => 'new value';
    is $scalar, 'new value', 'clobber predefined scalar if given a new value';
}
{
    my @array = (qw[test reset]);
    Readonly::Array @array;
    is_deeply \@array, [qw'test reset'], 'predefined list is not clobbered';
}
{
    my @array = (qw[test reset]);
    Readonly::Array @array => [qw'new list'];
    is_deeply \@array, [qw'new list'],
        'clobber predefined list if given a new value';
}
{
    my @array = (qw[test reset]);
    Readonly::Array @array => ('new', 'list');
    is_deeply \@array, [qw'new list'],
        'clobber predefined list if given a new value (part two!)';
}
{
    my %hash = %INC;
    Readonly::Hash %hash;
    is_deeply \%hash, \%INC, 'predefined hash is not clobbered';
}
{
    my %hash = %INC;
    Readonly::Hash %hash => {fun => 'new junk'};
    is_deeply \%hash, {fun => 'new junk'},
        'clobber predefined hash if given a new value';
}
{
    my %hash = %INC;
    Readonly::Hash %hash => (fun => 'new junk');
    is_deeply \%hash, {fun => 'new junk'},
        'clobber predefined hash if given a new value (part two!)';
}
#
done_testing;
