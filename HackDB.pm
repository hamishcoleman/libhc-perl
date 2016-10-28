package HC::HackDB;
use warnings;
use strict;
#
# A quick simple in-memory database.  I looked at using DBD::Anydata or
# DBD::CSV, but they looked like really big hammers
#

use Text::CSV;

use HC::HackDB::Row;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    #$self->_handle_args(@_);

    return $self;
}

sub _name2nr_helper {
    my $nr = 0;
    my $hash;
    for my $column (@_) {
        $hash->{$column} = $nr++;
    }
    return $hash;
}

sub _set_column_name2nr_raw {
    my $self = shift;
    $self->{column_name2nr} = shift;
    return $self;
}

sub set_column_names {
    my ($self) = shift;
    # cannot set the names twice
    return undef if (defined($self->_column_name2nr_raw()));
    return $self->_set_column_name2nr_raw(_name2nr_helper(@_));
}

sub set_rowdata {
    my ($self,$rownr,$data) = @_;
    @{$self->{data}}[$rownr] = $data;
    return $self;
}

sub _rowdata {
    my ($self,$rownr) = @_;
    return $self->{data}[$rownr];
}

sub _column_name2nr_raw {
    my ($self) = @_;
    return $self->{column_name2nr};
}

sub add_row {
    my ($self,$row) = @_;
    if (!defined($self->{column_name2nr})) {
        $self->_set_column_name2nr_raw($row->_column_name2nr_raw());
    }

    if ($row->_column_name2nr_raw() != $self->_column_name2nr_raw()) {
        # columns from this row are not a ref to the same columns as self
        return undef;
        # TODO - could check all the column names here...
    }

    $self->set_rowdata($self->_row_count(),$row->_rowdata());
    return $self;
}

sub row {
    my ($self,$rownr) = @_;
    return HC::HackDB::Row->new(
        $self->_column_name2nr_raw(),$self->_rowdata($rownr)
    );
}

sub empty_row {
    my $self = shift;
    my $data = [];
    return HC::HackDB::Row->new( $self->_column_name2nr_raw(),$data );
}

sub _row_count {
    my ($self) = @_;
    if (defined($self->{data})) {
        return scalar(@{$self->{data}});
    } else {
        return 0;
    }
}

sub load_csv {
    my ($self,$fh,$csv) = @_;

    if (!defined($csv)) {
        $csv = Text::CSV->new or return undef;
    }

    # nuke any existing data
    $self->{data} = [];

    while ($_ = $csv->getline($fh)) {
        $self->set_rowdata($self->_row_count(),$_);
    }

    return $self;
}

sub foreach {
    my ($self,$code) = @_;

    my $rownr=0;
    while ($rownr < $self->_row_count()) {
        $_ = $self->row($rownr++);
        &{$code}();
    }
}

sub query {
    my ($self) = shift;
    my %args = ( @_ );

    my $results = HC::HackDB->new();
    $self->foreach( sub {
        if ($_->match(%args)) {
            $results->add_row($_);
        }
    });
    return $results;
}

sub extract {
    my ($self) = shift;
    my @fields = @_;

    my $results = HC::HackDB->new();
    $results->set_column_names(@fields);

    $self->foreach( sub {
        my $row = $results->empty_row();
        $results->add_row($_->extract_into($row,@fields));
    });
    return $results;
}

sub column_names {
    my $self = shift;
    my $row = $self->row(0);
    return undef if (!defined($row));
    return $row->column_names();
}

sub to_string_columns {
    my ($self) = shift;
    my @columns = $self->column_names();
    return undef if (!@columns);
    return join(',',@columns);
}

sub to_string {
    my ($self) = shift;
    my @s;

    push @s,$self->to_string_columns();
    push @s,"\n";
    $self->foreach( sub {
        push @s,$_->to_string();
        push @s,"\n";
    });
    return join('',@s);
}

sub to_string_pretty {
    my $self = shift;
    my $grid;

    my @column_names = $self->column_names();

    my @col_widths;
    for my $col (0..scalar(@column_names)-1) {
        $col_widths[$col] = length($column_names[$col]);
    }

    $self->foreach( sub {
        my $fields = $_->_rowdata();    # FIXME - should have a public accessor
        for my $col (0..scalar(@{$fields})-1) {
            my $this_len = length($fields->[$col]) ||0;
            if ($this_len > $col_widths[$col]) {
                $col_widths[$col] = $this_len;
            }
        }
    });

    my @s;
    for my $col (0..scalar(@column_names)-1) {
        push @s, sprintf("%*s ",$col_widths[$col],$column_names[$col]);
    }
    push @s, "\n";
    $self->foreach( sub {
        my $fields = $_->_rowdata();    # FIXME - should have a public accessor
        for my $col (0..scalar(@column_names)-1) {
            push @s, sprintf("%*s ",$col_widths[$col],$fields->[$col]||'');
        }
        push @s, "\n";
    });
    return join('',@s);
}

1;
