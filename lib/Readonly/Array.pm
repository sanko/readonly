package Readonly::Array;
our $VERSION = '1.04';

sub TIEARRAY {
    my $whence
        = (caller 1)[3];    # Check if naughty user is trying to tie directly.
    Readonly::croak "Invalid tie" unless $whence =~ /^Readonly::Array1?$/;
    my $class = shift;
    my @self  = @_;
    return bless \@self, $class;
}

sub FETCH {
    my $self  = shift;
    my $index = shift;
    return $self->[$index];
}

sub FETCHSIZE {
    my $self = shift;
    return scalar @$self;
}

BEGIN {
    eval q{
        sub EXISTS {
           my $self  = shift;
           my $index = shift;
           return exists $self->[$index];
           }
    } if $] >= 5.006;    # couldn't do "exists" on arrays before then
}
*STORE = *STORESIZE = *EXTEND = *PUSH = *POP = *UNSHIFT = *SHIFT = *SPLICE
    = *CLEAR = *UNTIE = sub { Readonly::croak $Readonly::MODIFY};
