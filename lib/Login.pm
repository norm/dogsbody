package Login;

use Modern::Perl '2013';



# User-initiated login request. Redirect to Twitter sign in URL.
sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;
    
    my $url = $twitter->get_authentication_url(
            callback => sprintf '%s/login', $config->{''}{'url'}
        );

    $request->session->{'twitter_token'}  = $twitter->request_token;
    $request->session->{'twitter_secret'} = $twitter->request_token_secret;

    return [
        302,
        [
            'Location' => $url,
        ],
        []
    ];
}

# Callback request from Twitter after authorising the app, or plain login page.
sub get {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;

    my $verifier = $request->param('oauth_verifier');

    if ( defined $verifier ) {
        return get_with_verification(
                $config, $twitter, $jigsaw, $request, $verifier
            );
    }
    else {
        return get_plain_page( $config, $twitter, $jigsaw, $request );
    }
}

sub get_with_verification {
    my $config   = shift;
    my $twitter  = shift;
    my $jigsaw   = shift;
    my $request  = shift;
    my $verifier = shift;

    $twitter->request_token( $request->session->{'twitter_token'} );
    $twitter->request_token_secret( $request->session->{'twitter_secret'} );

    my( $access_token, $access_token_secret, $user_id, $screen_name )
        = $twitter->request_access_token( verifier => $verifier );
    
    if ( defined $access_token ) {
        if ( user_is_allowed( $config, $screen_name ) ) {
            $request->session->{'auth_type'}      = 'twitter';
            $request->session->{'twitter_name'}   = $screen_name;
            $request->session->{'twitter_id'}     = $user_id;
            $request->session->{'twitter_secret'} = $access_token;
            $request->session->{'twitter_token'}  = $access_token_secret;
        }
    }

    return [
        302,
        [
            'Location' => '/',
        ],
        []
    ];
}
sub user_is_allowed {
    my $config = shift;
    my $user   = shift;

    # if there's a 'users' section, this user must be in it, or no dice
    return defined $config->{'users'} 
        && defined $config->{'users'}{$user};

    # no 'users' section means anyone can use it
    return 1;
}

sub get_plain_page {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;

    my( $homepage, $errors ) = $jigsaw->render(
            'login',
            'html',
            {
                page => 'login',
            },
            {
                request => \$request,
                session => $request->session,
            },
        );
    
    return [
        200,
        [],
        [ $homepage ]
    ];
}

1;
