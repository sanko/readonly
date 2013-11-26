package Readonly::Hash;
our $VERSION = '1.04';

sub TIEHASH {
    my $whence
        = (caller 1)[3];    # Check if naughty user is trying to tie directly.
    Readonly::croak "Invalid tie" unless $whence =~ /^Readonly::Hash1?$/;
    my $class = shift;

    # must have an even number of values
    Readonly::croak $Readonly::ODDHASH unless (@_ % 2 == 0);
    my %self = @_;
    return bless \%self, $class;
}

sub FETCH {
    my $self = shift;
    my $key  = shift;
    return $self->{$key};
}

sub EXISTS {
    my $self = shift;
    my $key  = shift;
    return exists $self->{$key};
}

sub FIRSTKEY {
    my $self  = shift;
    my $dummy = keys %$self;
    return scalar each %$self;
}

sub NEXTKEY {
    my $self = shift;
    return scalar each %$self;
}
*STORE = *DELETE = *CLEAR = *UNTIE = sub { Readonly::croak $Readonly::MODIFY};
