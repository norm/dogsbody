package Permissions;

use Modern::Perl '2013';



sub is_authenticated {
    my $request = shift;
    
    return defined $request->session->{'twitter_name'};
}

1;
