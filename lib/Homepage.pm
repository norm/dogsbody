package Homepage;

use Modern::Perl '2013';



sub get {
    my $jigsaw = shift;
    my $request = shift;

    my( $homepage, $errors ) = $jigsaw->render(
            'homepage',
            'html',
            {
                page => 'homepage',
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
