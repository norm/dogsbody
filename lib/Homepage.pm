package Homepage;

use Modern::Perl '2013';



sub get {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;

    my @actions;
    foreach my $key ( keys %$config ) {
        my %action = %{ $config->{$key} };
        $action{'_key'} = $key;
        
        push @actions, \%action
            if $config->{$key}{'action'};
    }
    
    my( $homepage, $errors ) = $jigsaw->render(
            'homepage',
            'html',
            {
                page => 'homepage',
            },
            {
                actions => \@actions,
                context => Context::get_context( $config ),
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
