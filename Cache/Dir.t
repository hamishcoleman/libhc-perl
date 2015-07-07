# -*- perl -*-
use warnings;
use strict;
use Test::More;

BEGIN {
    use_ok('HC::Cache::Dir');
}

my $cache;
$cache = new_ok('HC::Cache::Dir');

is($cache->get('invalid/key1'),undef);
is($cache->get('testkey1'),undef);

is($cache->put('testkey3',1),undef);

my $testdata = {a => 'test'};
is($cache->put('invalid/key2',$testdata),undef);

isa_ok($cache->set_cachedir('/tmp/hc_cache_dir_test.'.$$),'HC::Cache::Dir');
is($cache->get('testkey2'),undef);
isa_ok($cache->put('testkey4',$testdata),'HC::Cache::Dir');

is_deeply($cache->get('testkey4'),$testdata);

done_testing();

