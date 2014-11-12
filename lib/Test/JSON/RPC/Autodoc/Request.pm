package Test::JSON::RPC::Autodoc::Request;
use strict;
use warnings;
use parent qw/HTTP::Request/;
use Clone qw/clone/;
use JSON qw/to_json/;
use Test::Builder;
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
    my $validator = Data::Validator->new(%params)->with('NoThrow');
    $self->{validator} = $validator;
    return $validator;
}

sub post_ok {
    my ($self, $method, $params) = @_;
    my $args = $self->{validator}->validate(%$params);
    my $ok = 1;
    $ok = 0 if $self->{validator}->has_errors;
    $self->{validator}->clear_errors();

    $self->_make_request($method, $params);

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    $ok = 0 if $res->code != 200;
    my $Test = Test::Builder->new();
    $Test->ok($ok);

    $self->{method} = $method;
    $self->{response} = $res;
    return $res;
}

sub post_not_ok {
    my ($self, $method, $params) = @_;
    my $args = $self->{validator}->validate(%$params);

    my $ok = 1 if $self->{validator}->has_errors;
    $self->{validator}->clear_errors();

    $self->_make_request($method, $params);

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    $ok = 1 if $res->code == 200;
    my $Test = Test::Builder->new();
    $Test->ok($ok);
}

sub _make_request {
    my ($self, $method, $params) = @_;
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
}

sub method { shift->{method} }
sub rule { shift->{rule} }

sub response {
    my $self = shift;
    return $self->{response} if $self->{response};
    return;
}

1;
