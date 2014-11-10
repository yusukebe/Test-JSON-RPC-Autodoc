package Test::JSON::RPC::Autodoc::Request;
use strict;
use warnings;
use Clone qw/clone/;
use HTTP::Request;
use JSON qw/to_json/;
use Test::More qw//;
use Try::Tiny;
use Test::JSON::RPC::Autodoc::Response;
use Test::JSON::RPC::Autodoc::Validator;
use Plack::Test::MockHTTP;

sub new {
    my ( $class, %opt ) = @_;
    my $self = bless {
        app  => $opt{app},
        path => $opt{path} || '/',
        id   => $opt{id} || 1
    }, $class;
    return $self;
}

sub params {
    my ($self, %params) = @_;
    return $self->{validator} unless %params;
    $self->{rule} = clone \%params;
    for my $p (%params) {
        next unless ref $p eq 'HASH';
        for my $key (keys %$p) {
            if ( $key eq 'required' ) {
                $p->{optional} = !$p->{required};
                delete $p->{$key};
            }
        }
    }
    my $validator = Data::Validator->new(%params);
    $self->{validator} = $validator;
    return $validator;
}

sub post_ok {
    my ($self, $method, $params) = @_;
    my $args = $self->{validator}->validate(%$params);
    my $json = to_json(
        {
            jsonrpc => '2.0',
            id => $self->{id},
            method  => $method,
            params  => $params,
        }, { pretty => 1 }
    );
    my $req = HTTP::Request->new(
        'POST', $self->{path},
        [
            'Content-Type' => 'application/json',
            'Content-Length' => length $json
        ],
        $json
    );

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($req);
    Test::More::is($res->code, 200);
    $self->{method} = $method;
    $self->{raw_request} = $req;
    $self->{response} = $res;
    return $res;
}

sub method { shift->{method} }
sub raw_request { shift->{raw_request} }
sub rule { shift->{rule} }

sub response {
    my $self = shift;
    return $self->{response} if $self->{response};
    return;
}

1;
