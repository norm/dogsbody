package Context;

use Modern::Perl '2013';

use Ouch qw( :traditional );
use Redis;
use Permissions;



sub post {
    my $config  = shift;
    my $twitter = shift;
    my $jigsaw  = shift;
    my $request = shift;

    throw 403 unless Permissions::is_authenticated( $request );

    my $redis = Redis->new();
    my $key   = sprintf '%s:context', $config->{''}{'redis_prefix'};

    $redis->set( $key, $request->param('context') );

    return [
        302,
        [
            'Location' => '/',
        ],
        []
    ];
}

sub get_context {
    my $config = shift;

    my $redis = Redis->new();
    my $key   = sprintf '%s:context', $config->{''}{'redis_prefix'};

    $redis->get( $key );
}

sub expand_context {
    my $config = shift;
    my $text = shift;

    my $context = get_context( $config );

    $text =~ s{%context}{$context};
    return $text;
}

1;
