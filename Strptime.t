# -*- perl -*-

use Test::More 'no_plan';

BEGIN {
    use_ok('HC::Strptime');
}

isa_ok(HC::Strptime->format(),'DateTime::Format::Strptime','Check date format');

my $parser = HC::Strptime->format();

my $datestring = '2013-10-25T09:00:00+1100';

my $d = $parser->parse_datetime($datestring);
is($d->epoch(), 1382652000, 'Can parse input datestring');
is($d->offset(), 39600, 'Can extract timezone offset');

$d->set_formatter($parser);
is($d, $datestring, 'Renders OK');

