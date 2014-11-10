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
    $dir = File::ShareDir::dist_dir('Test-JSON-RPC-Autodoc') unless -d $dir;
    my $tx = Text::Xslate->new( path => $dir );
    my $text = $tx->render('template.tx', { requests => $self->{requests} });
    path($self->{document_root}, $filename)->spew_utf8($text);
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::JSON::RPC::Autodoc - Generate documents automatically with the tests for JSON-RPC

=head1 SYNOPSIS

    use Test::More;
    use Plack::Request;
    use JSON qw/to_json from_json/;
    use Test::JSON::RPC::Autodoc;

    my $app = sub {
        my $env  = shift;
        my $req  = Plack::Request->new($env);
        my $ref  = from_json( $req->content );
        my $data = {
            jsonrpc => '2.0',
            id      => 1,
            result  => $ref->{params},
        };
        my $json = to_json($data);
        return [ 200, [ 'Content-Type' => 'application/json' ], [$json] ];
    };

    my $test = Test::JSON::RPC::Autodoc->new(
        document_root => './docs',
        app           => $app,
        path          => '/rpc'
    );

    my $rpc_req = $test->new_request();
    $rpc_req->params(
        language => { isa => 'Str', default => 'English', required => 1 },
        country => { isa => 'Str', documentation => 'Your country' }
    );
    $rpc_req->post_ok( 'echo', { language => 'Perl', country => 'Japan' } );
    my $res = $rpc_req->response();
    is $res->code, 200;
    my $data = $res->from_json();
    is $data->{result}{language}, 'Perl';

    $test->write('echo.md');
    done_testing();

=head1 DESCRIPTION

Test::JSON::RPC::Autodoc is ...

=head1 LICENSE

Copyright (C) Yusuke Wada.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yusuke Wada E<lt>yusuke@kamawada.comE<gt>

=cut

