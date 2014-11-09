package Test::JSON::RPC::Autodoc::Response;
use strict;
use warnings;
use HTTP::Message::PSGI;
use parent qw/HTTP::Response/;
use JSON qw//;

sub HTTP::Response::from_json {
    my $self = shift;
    my $content = $self->decoded_content();
    return unless $content;
    return JSON::from_json($content);
}

sub HTTP::Response::pretty_json {
    my $self = shift;
    my $content = $self->decoded_content();
    return unless $content;
    return JSON::to_json(JSON::from_json($content), { pretty => 1 });
}

1;
