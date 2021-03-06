package HC::HackDB::Row;
use warnings;
use strict;
#
# Represent a single row in a table
#

sub new {
    my $class = shift;
    my $name2nr = shift;
    my $rowdata = shift;

    return undef if (!defined($name2nr)); # need a column name mapping
    return undef if (!defined($rowdata)); # need a row

    my $self = {};
    bless $self, $class;

    $self->_set_column_name2nr($name2nr);
    $self->_set_rowdata($rowdata);
    return $self;
}

sub _set_column_name2nr {
    my ($self) = shift;
    $self->{column_name2nr} = shift;
    return $self;
}

sub _set_rowdata {
    my ($self) = shift;
    $self->{rowdata} = shift;
    return $self;
}

sub _rowdata { return shift->{rowdata}; }

sub _column_name2nr_raw {
    my $self = shift;
    return $self->{column_name2nr};
}

sub _column_name2nr {
    my ($self,$column) = @_;
    return $self->{column_name2nr}{$column};
}

# Given an existing column name, update that field to new data
sub _set_field {
    my ($self,$field,$val) = @_;
    my $fieldnr = $self->_column_name2nr($field);

    # Dont update a non-existant field
    return undef if (!defined($fieldnr));

    @{$self->_rowdata()}[$fieldnr] = $val;
    return $self;
}

# Add a new field heading if needed, then set the value of that field
sub _add_field {
    my ($self,$field,$val) = @_;

    # Dont add an existing field
    if (!defined($self->_column_name2nr($field))) {
        my $fieldnr = scalar( keys (%{$self->{column_name2nr}}));
        $self->{column_name2nr}{$field} = $fieldnr;
    }

    $self->_set_field($field,$val);
    return $self;
}

sub set_from_hash {
    my $self = shift;
    my $hash = shift;

    while (my ($key,$val) = each(%{$hash})) {
        $self->_add_field($key,$val);
    }
    return $self;
}

sub field {
    my ($self) = shift;
    my @result;
    for my $column (@_) {
        my $this = @{$self->_rowdata()}[$self->_column_name2nr($column)];
        if (!wantarray()) {
            return $this;
        }
        push @result, $this;
    }
    return @result;
}

sub match {
    my ($self) = shift;
    my %args = ( @_ );

    while (my ($fieldname,$tomatch) = each %args) {
        my $field = ($self->field($fieldname))[0];
        # TODO, support more than simply exact "eq"
        if ($tomatch ne $field) {
            return undef;
        }
    }
    return $self;
}

sub column_names {
    my ($self) = @_;
    my @columns;

    while (my ($field, $nr) = each %{$self->{column_name2nr}}) {
        $columns[$nr] = $field;
        # TODO - perhaps confirm that there are no overwrites?
    }

    return @columns;
}

sub extract_into {
    my $self = shift;
    my $empty_row = shift;

    my $rowdata;
    @{$rowdata} = $self->field(@_);
    $empty_row->_set_rowdata($rowdata);
    return $empty_row;
}

sub extract {
    my ($self) = shift;
    my @fields = @_;

    my $name2nr;

    my $nr = 0;
    for my $column (@fields) {
        $name2nr->{$column} = $nr++;
    }

    my $data = [];
    my $row = HC::HackDB::Row->new($name2nr,$data);
    return $self->extract_into($row,@fields);
}

sub to_string {
    my ($self) = shift;
    return join(',',@{$self->_rowdata()});
}

1;
