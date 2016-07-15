# Readonly clone tests
use strict;
use warnings;
use Test::More;
use lib '../../lib';
use ReadonlyX;

    #
    Readonly::Scalar my $scalar => 13;
    Readonly::Array my @array => (1, 2, 3);
    Readonly::Hash my %hash => (foo => 'bar');
    Readonly::Array my @deep_array => (1, \@array);
    Readonly::Hash my %deep_hash => (foo => \@array);
    #
    my $scalar_clone = Readonly::Clone $scalar;
    $scalar_clone++;
    is $scalar_clone, 14, 'scalar clone is mutable';
    #
    my @array_clone = Readonly::Clone @array;
    $array_clone[1] = 4;
    is $array_clone[1], 4, 'array clone is mutable';
    #
    my %hash_clone = Readonly::Clone %hash;
    $hash_clone{foo} = 'baz';
    is $hash_clone{foo}, 'baz', 'hash clone is mutable';
    #
    my @deep_array_clone = Readonly::Clone @deep_array;
    $deep_array_clone[1]->[2] = 4;
    is $deep_array_clone[1]->[2], 4, 'deep array clone is mutable';
    #
    my %deep_hash_clone = Readonly::Clone %deep_hash;
    $deep_hash_clone{foo}->[1] = 4;
    is $deep_hash_clone{foo}->[1], 4, 'deep hash clone is mutable';
    # }
{
    Readonly::Scalar my $scalar => ['string'];
    my $scalar_clone = Readonly::Clone $scalar;
    push @$scalar_clone, 'foo';
    is_deeply $scalar_clone, [qw[string foo]], 'listref clone is mutable';
}
{
    Readonly::Scalar my $scalar => ['string'];
    my @scalar_clone = Readonly::Clone $scalar;
    push @scalar_clone, 'foo';
    is_deeply \@scalar_clone, [qw[string foo]],
        'listref clone is mutable (take two)';
}
{
    Readonly::Scalar my $scalar => {qw[this that]};
    my $scalar_clone = Readonly::Clone $scalar;
    $scalar_clone->{'eh'} = 'foo';
    is_deeply $scalar_clone, {this => 'that', eh => 'foo'},
        'hashref clone is mutable';
    #
    my %scalar_clone = Readonly::Clone $scalar;
    $scalar_clone{'eh'} = 'foo';
    is_deeply [\%scalar_clone], [{this => 'that', eh => 'foo'}],
        'hashref clone is mutable (take two)';
}
#
done_testing;
