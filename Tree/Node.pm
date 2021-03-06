package HC::Tree::Node;
use warnings;
use strict;
#
# Often, I find myself building things that search down a tree structure.
# This class is a common ancestor for building these kind of trees
#
#

our $VERBOSE = 0;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self->_handle_args(@_);
}

sub _handle_args {
    my $self = shift;
    my %args = (
        @_,
    );
    while (my ($key,$val) = each(%args)) {
        if(!$self->can($key)) {
            # dont ask me to do something I cannot do!
            return undef;
        }
        $self->$key($val);
    }

    return $self;
}

sub _accessor {
    my $self = shift;
    my ($val) = @_;
    my $key = (caller(1))[3];
    $self->{$key}=$val if (defined($val));
    return $self->{$key};
}

# Returns the name of this node
sub name { my $self = shift; return $self->_accessor(@_); }

# The parent for this item (used for calculating the path to the root)
sub parent { my $self = shift; return $self->_accessor(@_); }

# For storing the object we are managing (if any)
sub data {my $self = shift; return $self->_accessor(@_); }

# Returns the list of all known objects under this node 
sub children {
    my $self = shift;
    # dummy node has no children
    return qw();
}

# Returns the list of all known children that match the search
sub search {
    my $self = shift;
    my $filter = shift;

    if (!defined($filter)) {
        # no search term given, just return ourselves
        return $self;
    }

    my @results = grep {($_->name()||'') =~ m/$filter/} $self->children();

    if (scalar(@results) > 1) {
        if (scalar(@_) > 0) {
            # if we got more than one result, we fail a multi-stage search
            return undef;
        }

        if (wantarray) {
            # return all the results as an array
            return @results;
        }

        # otherwise, it is an error to try to return multiple results if
        # we didnt want an array
        # FIXME - do something better here
        die("Cannot return multi-element result to a scalar");
    }

    # We get here if there is only one result
    my $result = $results[0];

    # We either want a multi-stage search
    if (scalar(@_) > 0) {
        if (!defined($result)) {
            # no match in the sub-search, so we fail the multi-stage search
            return undef;
        }
        return $result->search(@_);
    }

    # or if it is not a mult-stage search, we can just return the result
    return $result;
}

# Render this node
sub to_string {
    my $self = shift;
    my $s = $self->name();
    if ($VERBOSE && $self->can('to_string_verbose')) {
        $s .= " ";
        $s .= $self->to_string_verbose();
    }
    return $s;
}


# Render this node and all its children
sub to_string_recurse {
    my $self = shift;
    my %args = (
        maxdepth => undef,
        depth => 0,
        verbose => 0,
        @_,
    );

    # If we have recursed enough, stop
    return qw() if (defined($args{maxdepth}) && $args{maxdepth} > $args{depth});

    my @s;
    push @s,' 'x$args{depth}, $self->to_string(), "\n";

    $args{depth}++;

    # If we have recursed enough, stop
    return @s if (defined($args{maxdepth}) && $args{maxdepth} > $args{depth});

    my @sorted = sort {$a->name cmp $b->name} $self->children();
    for my $child (@sorted) {
        push @s, $child->to_string_recurse(%args);
    }
    if (wantarray) {
        return @s;
    }
    return join('',@s);
}

# Return the nodes that lead up to this one (inclusive)
sub path {
    my $self = shift;

    my @path;
    my $parent = $self;
    while (defined($parent)) {
        unshift @path, $parent;
        $parent = $parent->parent();
    }
    return @path;
}

# Return the path to this node as a tree
sub to_string_path {
    my $self = shift;
    my @path = $self->path();
    my @s;

    my $depth=0;
    for my $node (@path) {
        push @s,' 'x$depth,$node->to_string(),"\n";
        $depth++;
    }
    if (wantarray) {
        return @s;
    }
    return join('',@s);
}

sub to_string_treenode {
    my $self = shift;
    my @s;

    push @s,$self->to_string_path();
    my $depth = scalar($self->path());
    my @sorted = sort {$a->name cmp $b->name} $self->children();
    for my $node (@sorted) {
        push @s,' 'x$depth,$node->to_string(),"\n";
    }
    if (wantarray) {
        return @s;
    }
    return join('',@s);
}


1;

