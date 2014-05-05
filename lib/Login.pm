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

# Callback request from Twitter after authorising the app.
sub get {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;

    $twitter->request_token( $request->session->{'twitter_token'} );
    $twitter->request_token_secret( $request->session->{'twitter_secret'} );

    my( $access_token, $access_token_secret, $user_id, $screen_name )
        = $twitter->request_access_token(
              verifier => $request->param('oauth_verifier')
          );
    
    if ( defined $access_token ) {
        $request->session->{'auth_type'}      = 'twitter';
        $request->session->{'twitter_name'}   = $screen_name;
        $request->session->{'twitter_id'}     = $user_id;
        $request->session->{'twitter_secret'} = $access_token;
        $request->session->{'twitter_token'}  = $access_token_secret;
    }

    return [
        302,
        [
            'Location' => '/',
        ],
        []
    ];
}

1;
