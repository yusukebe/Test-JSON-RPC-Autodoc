package Test::JSON::RPC::Autodoc::Request;
use strict;
use warnings;
use parent qw/HTTP::Request/;
use Clone qw/clone/;
use JSON qw/to_json/;
use Test::More qw//;
use Try::Tiny;
use Test::JSON::RPC::Autodoc::Response;
use Test::JSON::RPC::Autodoc::Validator;
use Plack::Test::MockHTTP;

sub new {
    my ($class, %opt) = @_;
    my $self = $class->SUPER::new();
    $self->{method} = 'POST';
    $self->uri($opt{path} || '/');
    $self->{app} = $opt{app};
    $self->{id} = $opt{id} || 1;
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
    Test::More::ok $args;

    my $json = to_json(
        {
            jsonrpc => '2.0',
            id => $self->{id},
            method  => $method,
            params  => $params,
        }, { pretty => 1 }
    );
    $self->header('Content-Type' => 'application/json');
    $self->header('Content-Length' => length $json);
    $self->content($json);

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    Test::More::is($res->code, 200);
    $self->{method} = $method;
    $self->{response} = $res;
    return $res;
}

sub method { shift->{method} }
sub rule { shift->{rule} }

sub response {
    my $self = shift;
    return $self->{response} if $self->{response};
    return;
}

1;
