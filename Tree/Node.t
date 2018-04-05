# -*- perl -*-

use Test::More 'no_plan';

BEGIN {
    use_ok('HC::Tree::Node');
}
my $classname = 'HC::Tree::Node';
my $object;

$object = $classname->new(not_actually_a_mathod => 'fred');
is($object, undef);

$object = $classname->new(name => 'fred');
isa_ok($object, $classname);

is($object->name(),'fred');

is($object->parent(),undef);
is($object->data(),undef);

is($object->children(),qw());

is($object->to_string(),'fred');
# FIXME - verbose

# TODO -
# search - make a HC::Tree::Node subclass with children and test with that
# to_string - make a HC::Tree::Node subclass to_string_verbose
# to_string_recurse - make a HC::Tree::Node subclass with children
# path - build a deeper tree
# to_string_path - build a deeper tree
# to_string_treenode - make a HC::Tree::Node subclass with children

