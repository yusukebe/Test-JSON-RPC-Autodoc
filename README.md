[![Build Status](https://travis-ci.org/yusukebe/Test-JSON-RPC-Autodoc.svg?branch=master)](https://travis-ci.org/yusukebe/Test-JSON-RPC-Autodoc)
# NAME

Test::JSON::RPC::Autodoc - Generate documents automatically with the tests for JSON-RPC

# SYNOPSIS

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

# DESCRIPTION

Test::JSON::RPC::Autodoc is ...

# LICENSE

Copyright (C) Yusuke Wada.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Yusuke Wada <yusuke@kamawada.com>
