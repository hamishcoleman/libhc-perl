# -*- perl -*-

use Test::More 'no_plan';

BEGIN {
    use_ok('HC::Common');
}

my $option = {
    opt1 => 'set_opt1',
};
my @option_list = (
    "opt1|o=s",
    "opt2|p=i",
    "quiet",
    "verbose+",
);

@ARGV = qw( --opt1=test1 --opt2=10 );

HC::Common::do_options($option,@option_list);

is($option->{opt1}, 'test1', 'Commandline option');
is($option->{opt2}, '10',    'Commandline option');

@ARGV = qw( --quiet --verbose );
HC::Common::do_options($option,@option_list);

ok($option->{quiet});
ok(! exists $option->{verbose});

#@ARGV = qw( --help );
#HC::Common::do_options($option,@option_list);
## TODO - how to test the output?

is(HC::Common::hexdump(undef),undef);
my $buf="a\x0fcde\x80";
is(
    HC::Common::hexdump($buf),
    '000: 61 0f 63 64 65 80                               | a cde ',
    'Check hexdump'
);

$buf="0123456789ABCDEFGHIJKLMNOP";
is(
    HC::Common::hexdump($buf),
    "000: 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46 | 0123456789ABCDEF\n".
    "010: 47 48 49 4a 4b 4c 4d 4e 4f 50                   | GHIJKLMNOP",
    'Check hexdump'
);

