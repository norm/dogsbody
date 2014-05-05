#!/usr/bin/env perl
use Modern::Perl '2013';

use Config::Std;
use Net::Twitter;
use Ouch qw( :traditional );
use Plack::Builder;
use Plack::Request;
use Plack::Session::Store::Redis;
use Template::Jigsaw;
use URI::Dispatch;

use Homepage;
use Login;
use Logout;
use Tweet;

use constant ONE_DAY => ( 60 * 60 * 24 );

read_config 'app.conf' => my %config;

my $jigsaw = Template::Jigsaw->new( 'templates' );

my $twitter = Net::Twitter->new(
        consumer_key        => $config{''}{'key'},
        consumer_secret     => $config{''}{'secret'},
        access_token        => $config{''}{'access_token'},
        access_token_secret => $config{''}{'access_secret'},
        traits              => [ 'API::RESTv1_1', 'OAuth', ],
        ssl                 => 1,
    );

my $dispatch = URI::Dispatch->new();
$dispatch->add( '/', 'Homepage' );
$dispatch->add( '/login', 'Login' );
$dispatch->add( '/logout', 'Logout' );
$dispatch->add( '/tweet', 'Tweet' );

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
    enable 'Session',
        store => Plack::Session::Store::Redis->new(
            prefix  => "${config{''}{'redis_prefix'}}:session:",
            expires => ONE_DAY,
        );
    $app;
}
