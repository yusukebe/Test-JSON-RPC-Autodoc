use strict;
use Test::More;
use FindBin;
use Plack::Request;
use JSON qw/to_json from_json/;
use Test::JSON::RPC::Autodoc;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    return [500, [], ['{"error":1}']] if $req->uri->path !~ m!^/rpc$!;
    return [500, [], ['{"error":1}']] if $req->method ne 'POST';
    my $params = from_json($req->content);
    return [500, [], ['{"error":1}']] if $params->{method} ne 'echo';
    my $data = {
        jsonrpc => '2.0',
        id => 1,
        result  => $params->{params},
    };
    my $json = to_json($data);
    return [ 200, [ 'Content-Type' => 'application/json' ], [$json] ];
};

my $test = Test::JSON::RPC::Autodoc->new(
    document_root => $FindBin::Bin,
    app => $app,
    path => '/rpc'
);

my $rpc_req = $test->new_request();
$rpc_req->params(
    language => { isa => 'Str', default => 'English', required => 1, documentation => 'Your language' },
    country => { isa => 'Str', documentation => 'Your country' }
);
$rpc_req->post_ok('echo', { language => 'Perl', country => 'Japan' });
my $res = $rpc_req->response();
is $res->code, 200;
my $data = $res->from_json();
is_deeply $data->{result}, { language => 'Perl', country => 'Japan' };

$test->write('sample.md');

done_testing();
