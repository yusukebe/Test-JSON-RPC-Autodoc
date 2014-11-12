requires 'perl', '5.008001';
requires 'parent';
requires 'HTTP::Message';
requires 'Clone';
requires 'JSON';
requires 'Path::Tiny';
requires 'Plack';
requires 'Data::Validator';
requires 'File::ShareDir';
requires 'Text::Xslate';
requires 'Test::Simple';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal', '0.013';
};

