# -*- perl -*-
use Test::More 'no_plan';
use warnings;
use strict;

my $class = "HC::HexDump";
use_ok($class);

is(HC::HexDump::hexdump(undef), undef);

my $buf;
my $expect;

$buf= "abcdefghijklmnopqrstuvwxyz0123456789\n\x80";
$expect ="000: 61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f 70 | abcdefghijklmnop\n";
$expect.="010: 71 72 73 74 75 76 77 78 79 7a 30 31 32 33 34 35 | qrstuvwxyz012345\n";
$expect.="020: 36 37 38 39 0a 80                               | 6789  ";

is(HC::HexDump::hexdump(\$buf), $expect);

$expect ="000: 61 62 63 64 65 66 67 68 69 6a 6b 6c 6d 6e 6f 70 | abcdefghijklmnop\n";
$expect.="010: 71 72 73 74 75 76 77 78                         | qrstuvwx";

is(HC::HexDump::hexdump(\$buf, 0x18), $expect);
