package Logout;

use Modern::Perl '2013';



# User-initiated logout request.
sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;
    
    $request->session_options->{'expire'} = 1;
    
    return [
        302,
        [
            'Location' => '/',
        ],
        []
    ];
}

1;
