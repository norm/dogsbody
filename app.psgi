#!/usr/bin/env perl
use Modern::Perl '2013';

use Config::Std;
use Net::Twitter;
use Ouch qw( :traditional );
use Plack::Builder;
use Plack::Request;
use Template::Jigsaw;
use URI::Dispatch;

use Homepage;
use Login;
use Logout;

read_config 'app.conf' => my %config;

my $jigsaw = Template::Jigsaw->new( 'templates' );

my $twitter = Net::Twitter->new(
        consumer_key        => $config{''}{'key'},
        consumer_secret     => $config{''}{'secret'},
        traits              => [ 'API::RESTv1_1', 'OAuth', ],
        ssl                 => 1,
    );

my $dispatch = URI::Dispatch->new();
$dispatch->add( '/', 'Homepage' );
$dispatch->add( '/login', 'Login' );
$dispatch->add( '/logout', 'Logout' );

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );
    my $response;
    
    try {
        $response = $dispatch->dispatch( $req, \%config, $twitter, $jigsaw );
    };
    if ( catch 404 ) {
        $response = [ 404, [], [ 'Bummer' ] ];
    }
    
    return $response;
};

builder {
    enable 'Session';
    $app;
}
