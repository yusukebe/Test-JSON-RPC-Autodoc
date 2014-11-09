package Test::JSON::RPC::Autodoc;
use 5.008001;
use strict;
use warnings;
use File::ShareDir;
use Path::Tiny qw/path/;
use Text::Xslate;
use Test::JSON::RPC::Autodoc::Request;

our $VERSION = "0.01";

sub new {
    my ($class, %opt) = @_;
    my $app = $opt{app} or die 'app parameter must not be null!';
    my $self = bless {
        app => $app,
        document_root => $opt{document_root} || 'docs',
        path => $opt{path} || '/',
        requests => [],
    }, $class;
    return $self;
}

sub new_request {
    my $self = shift;
    my $req = Test::JSON::RPC::Autodoc::Request->new(
        app => $self->{app}, path => $self->{path}
    );
    push @{$self->{requests}}, $req;
    return $req;
}

sub write {
    my ($self, $filename) = @_;
    my $dir = './share';
    $dir = File::ShareDir::dist_file('Test-JSON-RPC-Auto') unless -d $dir;
    my $template = path($dir)->child('template.tx');
    my $tx = Text::Xslate->new();
    my $text = $tx->render($template, { requests => $self->{requests} });
    path($self->{document_root}, $filename)->spew_utf8($text);
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::JSON::RPC::Autodoc - It's new $module

=head1 SYNOPSIS

    use Test::JSON::RPC::Autodoc;

=head1 DESCRIPTION

Test::JSON::RPC::Autodoc is ...

=head1 LICENSE

Copyright (C) Yusuke Wada.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yusuke Wada E<lt>yusuke@kamawada.comE<gt>

=cut

