#!/usr/bin/env perl
use Modern::Perl '2013';

use Config::Std;
use Net::Twitter;

read_config 'app.conf' => my %config;

my $twitter = Net::Twitter->new(
        consumer_key        => $config{''}{'key'},
        consumer_secret     => $config{''}{'secret'},
        traits              => [ 'API::RESTv1_1', 'OAuth', ],
        ssl                 => 1,
    );

say $twitter->get_authorization_url( callback => $config{'url'} );
