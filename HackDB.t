# -*- perl -*-

use Test::More 'no_plan';


BEGIN {
    use_ok('HC::HackDB');
}

my $classname = 'HC::HackDB';
my $object;

$object = new_ok($classname);

my @column_names = qw(id name comment);
is($object->set_column_names(@column_names),$object);

my $row0 = [1,"dog","a friendly one"];
my $row1 = [2,"cat","somewhat aloof"];

# add a row or two
$object->set_rowdata(0,$row0);
$object->set_rowdata(1,$row1);

my $row = $object->row(0);
isa_ok($row,$classname.'::Row');
is($row->column_names(),@column_names);
my ($field1, $field2) = $row->field('id','name');
is($field1,1);
is($field2,'dog');

my $result = $object->query(id=>2);
isa_ok($result,$classname);

$row = $result->row(0);
isa_ok($row,$classname.'::Row');
is($row->column_names(),@column_names);
($field1, $field2) = $row->field('id','name');
is($field1,2);
is($field2,'cat');

$result = $object->extract('id','comment');
$row = $result->row(1);
isa_ok($row,$classname.'::Row');
my @new_cols = $row->column_names();
is_deeply(\@new_cols, ['id','comment']);
($field1, $field2) = $row->field('id','comment');
is($field1,2);
is($field2,'somewhat aloof');

is($result->to_string_columns(),'id,comment');
is($result->to_string(),"id,comment\n1,a friendly one\n2,somewhat aloof\n");

my $expected = <<EOF;
id        comment 
 1 a friendly one 
 2 somewhat aloof 
EOF

is($result->to_string_pretty(),$expected);

# TODO:
# load_csv - add an external file
