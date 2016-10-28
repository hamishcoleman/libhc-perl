# -*- perl -*-

use Test::More 'no_plan';

BEGIN {
    use_ok('HC::HackDB::Row');
}
my $classname = 'HC::HackDB::Row';
my $object;

my $column_name2nr = {
    value   => 0,
    date    => 1,
    comment => 2,
};
my $column = ['300', '1970-01-10', 'Pay rent'];

$object = $classname->new($column_name2nr,$column);
isa_ok($object,$classname);

is($object->field('value'),300);

my @column_names;
@column_names = $object->column_names();
is_deeply(\@column_names, ['value','date','comment']);

is($object->_add_field('direction','incoming'),$object);
@column_names = $object->column_names();
is_deeply(\@column_names, ['value','date','comment','direction']);

is($object->to_string(),'300,1970-01-10,Pay rent,incoming');

is($object->extract('direction','value')->to_string(),'incoming,300');

# TODO:
# _set_field
# _add_field
# match - currently covered by HC::HackDB
# extract - currently covered by HC::HackDB

