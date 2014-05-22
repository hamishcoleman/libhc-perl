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


