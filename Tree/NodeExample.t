# -*- perl -*-

use Test::More 'no_plan';

BEGIN {
    use_ok('HC::Tree::NodeExample');
}

my $classname = 'HC::Tree::NodeExample';

my $obj1 = $classname->new(name => 'Top');
isa_ok($obj1, $classname);

my $obj2 = $classname->new(
    name   => 'Mid2',
    parent => $obj1,
);
isa_ok($obj2, $classname);

my $obj3 = $classname->new(
    name   => 'Mid3',
    parent => $obj1,
);
isa_ok($obj3, $classname);

# set children
$obj1->data( [$obj2, $obj3] );

my $obj4 = $classname->new(
    name   => 'Mid2.4',
    parent => $obj2,
);
isa_ok($obj4, $classname);

my $obj5 = $classname->new(
    name   => 'Mid2.5',
    parent => $obj2,
);
isa_ok($obj5, $classname);

# set children
$obj2->data( [$obj4, $obj5] );

my $obj6 = $classname->new(
    name   => 'Mid2.4.6',
    parent => $obj4,
);
isa_ok($obj6, $classname);

my $obj7 = $classname->new(
    name   => 'Mid2.4.7',
    parent => $obj4,
);
isa_ok($obj7, $classname);

# set children
$obj4->data( [$obj6, $obj7] );

my $expect = <<EOF;
Top
 Mid2
  Mid2.4
   Mid2.4.6
   Mid2.4.7
  Mid2.5
 Mid3
EOF
is($obj1->to_string_recurse(), $expect);

# TODO
# - mto_string_recurse with maxdepth

is($obj1->search(), $obj1, 'No search string, return self');
is($obj1->search('Mid2'), $obj2, 'Single level search');
is($obj1->search('Mid2','Mid2.5'), $obj5, 'Multi level search');

is($obj1->search('fred', 'larry'), undef, 'Search with no match');
is($obj1->search('Mid.','Mid2.5'), undef, 'Search with non uniqe midpart');

my @results = $obj1->search('Mid2','Mid2.*');
is($results[0], $obj4, 'Wildcard search returns both obj4');
is($results[1], $obj5, 'and obj5');

$expect = <<EOF;
Top
 Mid2
  Mid2.4
EOF
is($results[0]->to_string_path(), $expect);

$expect = <<EOF;
Top
 Mid2
  Mid2.4
   Mid2.4.6
   Mid2.4.7
EOF
is($results[0]->to_string_treenode(), $expect);

$HC::Tree::Node::VERBOSE=1;
$expect = <<EOF;
Top Verbose Data
 Mid2 Verbose Data
  Mid2.4 Verbose Data
   Mid2.4.6 Verbose Data
   Mid2.4.7 Verbose Data
EOF
is($results[0]->to_string_treenode(), $expect);

# TODO
# - search()
#   - has a special case for nodes with no name
#   - perform a search returning multiple objects but not wantarray == die
# - to_string()
#   - VERBOSE on an object that has no to_string_verbose() method
# - to_string_recurse()
#   - maxdepth x2 - NOTE, the logic actually looks wrong here!
