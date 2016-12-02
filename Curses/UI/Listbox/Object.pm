package HC::Curses::UI::Listbox::Object;
use warnings;
use strict;
#
# A version of Curses::UI::Listbox that is slightly more object oriented than
# the original
#

use base qw(Curses::UI::Listbox);

sub new() {
    my $class = shift;
    my %userargs = @_;

    my $self = $class->SUPER::new( %userargs );
    return undef if (!defined($self));

    $self->labels($self->RenderLabels());

    $self->set_routine('option-select', \&view_object);

    # todo
    # - mouseclick moves selection, but does not activate it
    # - doubleclock can still activate

    return $self;
}

sub RenderLabels() {
    my $self = shift;

    my $labels;
    foreach (@{$self->{-values}}) {
        if ($_->can('RenderLabel')) {
            $labels->{$_} = $_->RenderLabel();
        } else {
            # otherwise, simply stringify the object
            $labels->{$_} = ''. $_;
        }
    }
    return $labels;
}

sub view_object() {
    my $listbox = shift;

#    # set the highlighted object to be the selected one
#    $listbox->{-selected} = $listbox->{-ypos};
#    # Get the selected object
#    my $object = $listbox->get;
#    $this->{-selected} = undef;

    # TODO:
    #my @objects = $listbox->get();
    #for each @objects, rendervalue

    my $object = $listbox->get_active_value();
    if ($object->can('RenderValue')) {
        $object->RenderValue($listbox);
    }
}

# requery / refresh
# layout / resize?

1;

