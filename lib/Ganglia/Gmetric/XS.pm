package Ganglia::Gmetric::XS;

use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Ganglia::Gmetric::XS', $VERSION);

sub new {
    my $class = shift;
    my %args  = @_;

    my $config = delete $args{config} || "/etc/gmond.conf";
    warn "config: $config"; # fixme

    return initialize_ganglia($class, $config);
}

1;

__END__

=head1 NAME

Ganglia::Gmetric::XS - send a metric value to gmond with libganglia C library

=head1 SYNOPSIS

    use Ganglia::Gmetric::XS;

    my $gm = Ganglia::Gmetric::XS->new(config => "/etc/gmond.conf");
    $gm->send( name => "db_conn", value => 32, type => "uint32", unit => "connection" );

=head1 DESCRIPTION

FIXME

=head1 FUNCTIONS

or FIXME

=head1 METHODS

=head2 new

  $obj = Ganglia::Gmetric::XS->new( %option )

FIXME ...

=head2 some_method

  $ret = $obj->some_method

FIXME ...

=head1 SEE ALSO

L<Some::Module::FIXME>
L<http://www.perl.org/FIXME>

=head1 AUTHOR

HIROSE Masaaki, C<< <hirose@klab.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-ganglia-gmetric-xs@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
