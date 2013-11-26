package Readonly::Scalar;
our $VERSION = '1.04';

sub TIESCALAR {
    my $whence
        = (caller 2)[3];    # Check if naughty user is trying to tie directly.
    Readonly::croak "Invalid tie"
        unless $whence && $whence =~ /^Readonly::(?:Scalar1?|Readonly)$/;
    my $class = shift;
    Readonly::croak "No value specified for readonly scalar" unless @_;
    Readonly::croak "Too many values specified for readonly scalar"
        unless @_ == 1;
    my $value = shift;
    return bless \$value, $class;
}

sub FETCH {
    my $self = shift;
    return $$self;
}
*STORE = *UNTIE = sub { Readonly::croak $Readonly::MODIFY};
