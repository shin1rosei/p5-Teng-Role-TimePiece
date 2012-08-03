package Teng::Role::TimePiece;
use strict;
use warnings;
our $VERSION = '0.01';

use Any::Moose '::Role';

our $TIMEPIECE_CLASS = 'Time::Piece';
our $STRPTIME_FORMAT = '%Y-%m-%d %H:%M:%S';

Any::Moose::load_class($TIMEPIECE_CLASS);

around new => sub {
    my $orig  = shift;
    my $class = shift;

    my $self   = $class->$orig(@_);

    for my $table_name (keys %{$self->schema->tables}) {
        my $table = $self->schema->get_table($table_name);
        $table->add_deflator(
            qr/^.+_at$/, 
            sub {
                my $col_value = shift;
                return $col_value unless $col_value;

                if (ref $col_value eq $TIMEPIECE_CLASS) {
                    return $col_value->datetime;
                }

                return $col_value;
            });

        $table->add_inflator(
            qr/^.+_at$/,
            sub {
                my $col_value = shift;

                return $TIMEPIECE_CLASS->localtime(
                    $TIMEPIECE_CLASS->strptime(
                        $col_value, $STRPTIME_FORMAT));
            });
    }

    $self;
};

1;
__END__

=head1 NAME

Teng::Role::TimePiece - using Time::Piece for datetime column 

=head1 SYNOPSIS

  use Teng::Role::TimePiece;

=head1 DESCRIPTION
=head1 AUTHOR

Shinichiro Sei E<lt>shin1rosei@kayac.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
