package Action;

use Modern::Perl '2013';

use Context;
use Ouch qw( :traditional );



# Pre-configured actions (such as tweets using centrally configured twitter 
# account, not the logged-in user account)
sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;
    my $args    = shift;

    my $slug = $args->{'slug'};
    my $action = $config->{$slug};

    throw 404 unless $action;

    if ( 'tweet' eq $action->{'action'} ) {
        try {
            my $text = Context::expand_context( $config, $action->{'status'} );
            $twitter->update( $text );
        };
        if ( catch_all ) {
            warn "Error posting update occured: $@";
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

1;
