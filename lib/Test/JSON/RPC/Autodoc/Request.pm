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
use Data::Recursive::Encode;

sub new {
    my ($class, %opt) = @_;
    my $self = $class->SUPER::new();
    $self->{method} = 'POST';
    $self->uri($opt{path} || '/');
    $self->{app} = $opt{app};
    $self->{id} = $opt{id} || 1;
    $self->{label} = $opt{label} || '';
    return $self;
}

sub params {
    my ($self, %params) = @_;
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

sub validator {
    my $self = shift;
    return $self->{validator} if $self->{validator};
    return Data::Validator->new->with('NoThrow');
}

sub post_ok {
    my ($self, $method, $params, $headers) = @_;
    $params ||= {};
    my $args = $self->validator->validate(%$params);
    my $ok = 1;
    $ok = 0 if $self->validator->has_errors;
    $self->validator->clear_errors();

    $self->_make_request($method, $params, $headers);

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    $ok = 0 if $res->code != 200;
    my $Test = Test::Builder->new();
    $Test->ok($ok);

    $self->{response} = $res;
    return $res;
}

sub post_not_ok {
    my ($self, $method, $params, $headers) = @_;
    $params ||= {};
    my $args = $self->validator->validate(%$params);

    my $ok = 1 if $self->validator->has_errors;
    $self->validator->clear_errors();

    $self->_make_request($method, $params, $headers);

    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    $ok = 1 if $res->code == 200;
    my $Test = Test::Builder->new();
    $Test->ok($ok);
}

sub post_only {
    my ($self, $params, $method, $headers) = @_;
    $self->_make_request($method, $params, $headers);
    my $mock = Plack::Test::MockHTTP->new($self->{app});
    my $res = $mock->request($self);
    return $res;
}

sub _make_request {
    my ($self, $method, $params, $headers) = @_;
    $params = Data::Recursive::Encode->encode_utf8($params);
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
    if($headers && ref $headers eq 'ARRAY') {
        for my $header (@$headers) {
            $self->header(@$header);
        }
    }
    $self->content($json);
}

sub method { shift->{method} }
sub rule { shift->{rule} }
sub label { shift->{label} }

sub response {
    my $self = shift;
    return $self->{response} if $self->{response};
    return;
}

1;
