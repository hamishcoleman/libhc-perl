# -*- perl -*-

use Test::More 'no_plan';


BEGIN {
    use_ok('HC::Base64Sortable');
}

is(encode_base64sortable(undef),'');
is(encode_base64sortable('a'),'OG');
is(encode_base64sortable('z'),'UW');

is(encode_base64sortable(0),'C0');
is(encode_base64sortable(1),'CG');
is(encode_base64sortable(2),'CW');

is(encode_base64sortable(10),'CJ0');
is(encode_base64sortable(11),'CJ4');
is(encode_base64sortable(12),'CJ8');

is(encode_base64sortable(100),'CJ0l');
is(encode_base64sortable(101),'CJ0m');
is(encode_base64sortable(102),'CJ0n');

