use strict;
use warnings;
use lib '../lib';
use Benchmark;
my $scalar;
{

    package constant;
    use constant CONST_SCALAR => 'Fourscore and seven years ago...';
    use constant CONST_HASH   => {key => 'value'};
    use constant CONST_ARRAY  => qw[dog cat bird fish];
    sub scalar { $scalar = CONST_SCALAR; }
    sub hash   { $scalar = CONST_HASH->{key}; }
    sub array  { $scalar = (CONST_ARRAY)[1]; }
}
{

    package normal;
    my $normal_scalar = 'Fourscore and seven years ago...';
    my %normal_hash   = (key => 'value');
    my @normal_array  = (qw[dog cat bird fish]);
    sub scalar { $scalar = $normal_scalar; }
    sub hash   { $scalar = $normal_hash{key}; }
    sub array  { $scalar = $normal_array[1]; }
}
{

    package readonly;
    use namespace::clean;
    my ($normal_scalar, %normal_hash, @normal_array);
    eval <<'END';
    use Readonly;
    Readonly::Scalar $normal_scalar => 'Fourscore and seven years ago...';
    Readonly::Hash %normal_hash     => {key => 'value'};
    Readonly::Array @normal_array   => qw[dog cat bird fish];
END
    sub scalar { $scalar = $normal_scalar; }
    sub hash   { $scalar = $normal_hash{key}; }
    sub array  { $scalar = $normal_array[1]; }
}
{

    package readonlyx;
    my ($normal_scalar, %normal_hash, @normal_array);
    eval <<'END';
    use ReadonlyX;
    Readonly::Scalar $normal_scalar => 'Fourscore and seven years ago...';
    Readonly::Hash %normal_hash     => {key => 'value'};
    Readonly::Array @normal_array   => qw[dog cat bird fish];
END
    sub scalar { $scalar = $normal_scalar; }
    sub hash   { $scalar = $normal_hash{key}; }
    sub array  { $scalar = $normal_array[1]; }
}
#
my %tests = (scalar => {const     => \&constant::scalar,
                        normal    => \&normal::scalar,
                        readonlyx => \&readonlyx::scalar,
                        readonly  => \&readonly::scalar
             },
             hash => {const     => \&constant::hash,
                      normal    => \&normal::hash,
                      readonlyx => \&readonlyx::hash,
                      readonly  => \&readonly::hash
             },
             array => {const     => \&constant::array,
                       normal    => \&normal::array,
                       readonlyx => \&readonlyx::array,
                       readonly  => \&readonly::array
             }
);
#
for my $type (keys %tests) {
    print ucfirst $type . ' ';
    timethese(5_000_000, $tests{$type});
}
