package Ganglia::Gmetric::XS;

use strict;
use warnings;
use Carp;

our $VERSION = '0.02';

require XSLoader;
XSLoader::load('Ganglia::Gmetric::XS', $VERSION);

sub new {
    my $class = shift;
    my %args  = @_;

    my $config = delete $args{config} || "/etc/gmond.conf";
    return _ganglia_initialize($class, $config);
}

sub send {
    my($self,%args) = @_;

    return _ganglia_send(
        $self,
        $args{name}  || "",
        $args{value} || "",
        $args{type}  || "",
        $args{units} || "",
        3, 60, 0);
}

1;

__END__

=head1 NAME

Ganglia::Gmetric::XS - send a metric value to gmond with libganglia C library

=head1 SYNOPSIS

    use Ganglia::Gmetric::XS;

    my $gg = Ganglia::Gmetric::XS->new(config => "/etc/gmond.conf");
    $gg->send(name  => "db_conn",
              value => 32,
              type  => "uint32",
              unit  => "connection",
             );

=head1 DESCRIPTION

Ganglia::Gmetric::XS can send a metric value to gmond with libganglia
C library.

=head1 METHODS

=head2 new

  $gg = Ganglia::Gmetric::XS->new( %option );

This method constructs a new "Ganglia::Gmetric::XS" instance and
returns it. %option is following:

  KEY    VALUE
  ----------------------------
  config "/etc/gmond.conf"

=head2 send

  $gg->send( %param ) or carp "failed to send metric";

do send a metric value. %param is following:

  KEY    VALUE
  ----------------------------
  name   name of the metric
  value  value of the metric
  type   either string|int8|uint8|int16|uint16|int32|uint32|float|double
  units  unit of measure for the value e.g. "Kilobytes", "Celcius"

=head2 enabled_clear_pool

  print $gg->enabled_clear_pool ? "true" : "false";

return true if you specify --enable-clear-pool option at "perl Makefile.PL".
see also README file.

=head1 SEE ALSO

L<http://ganglia.info>

=head1 AUTHOR

HIROSE Masaaki, C<< <hirose@klab.org> >>

=head1 REPOSITORY

L<http://github.com/hirose31/ganglia-gmetric-xs/tree/master>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-ganglia-gmetric-xs@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
