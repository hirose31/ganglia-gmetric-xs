# -*- mode: cperl; -*-
use Test::Dependencies
    exclude => [qw(Test::Dependencies Test::Base Test::Perl::Critic
                   Ganglia::Gmetric::XS)],
    style   => 'light';
ok_dependencies();
