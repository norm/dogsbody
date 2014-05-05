package Tweet;

use Modern::Perl '2013';

use Context;
use Ouch qw( :traditional );
use Permissions;



# User-initiated tweet, using centrally configured twitter account
# (note, not the logged-in user account)
sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;
    
    throw 403 unless Permissions::is_authenticated( $request );

    try {
        my $text = Context::expand_context( $config, $request->param('tweet') );
        $twitter->update( $text );
    };
    if ( catch_all ) {
        warn "Error posting update occured: $@";
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
