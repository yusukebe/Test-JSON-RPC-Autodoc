[![Build Status](https://travis-ci.org/yusukebe/Test-JSON-RPC-Autodoc.png?branch=master)](https://travis-ci.org/yusukebe/Test-JSON-RPC-Autodoc)
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

**Test::JSON::RPC::Autodoc** is a software for testing JSON-RPC Web applications. This module generate the Markdown formatted documentations about RPC parameters, requests, and responses. Using **Test::JSON::RPC::Autodoc**, we write the integrated tests, then these will be useful to share the JSON-RPC parameter rules with other developers.

# METHODS

## **new(%options)**

    my $test = Test::JSON::RPC::Autodoc->new(
        app => $app, # PSGI application, required
        document_root => './documents', # output directory for documents, optional, default is './docs'
        path => '/rpc' # JSON-RPC endpoint path, optional, default is '/'
    );

Create a new Test::JSON::RPC::Autodoc instance. Possible options are:

- `app => $app`

    PSGI application, required.

- `document_root => './documents'`

    Output directory for documents, optional, default is './docs'.

- `path => '/rpc'`

    JSON-RPC endpoint path, optional, default is '/'.

## **new\_request()**

Return a new Test::JSON::RPC::Autodoc::Request instance.

## **write('echo.md')**

# SEE ALSO

- [Test::JsonAPI::Autodoc](https://metacpan.org/pod/Test::JsonAPI::Autodoc)
- "autodoc": [https://github.com/r7kamura/autodoc](https://github.com/r7kamura/autodoc)

# LICENSE

Copyright (C) Yusuke Wada.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Yusuke Wada <yusuke@kamawada.com>
