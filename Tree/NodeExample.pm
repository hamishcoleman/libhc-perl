package HC::Tree::NodeExample;
use warnings;
use strict;
#
# A simple example using the HC::Tree:Node class
#

use base qw(HC::Tree::Node);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub children {
    my $self = shift;
    my $data = $self->data();
    if (!defined($data)) {
        return qw();
    }

    return @{$data};
}

sub to_string_verbose {
    my $self = shift;
    return "Verbose Data";
}

1;
