package Tweet;

use Modern::Perl '2013';



# User-initiated tweet, using centrally configured twitter account
# (note, not the logged-in user account)
sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;
    
    $twitter->update( $request->param('tweet') );
    
    return [
        302,
        [
            'Location' => '/',
        ],
        []
    ];
}

1;
