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

    $self->{__stack} = [];
    $self->{__stack_pos} = [];

    $self->RenderLabels();

    $self->set_routine('option-select', \&view_object);

    # todo
    # - mouseclick moves selection, but does not activate it
    # - doubleclock can still activate

    return $self;
}

# Take the current values and save them for later
sub PushValues() {
    my $self = shift;

    push @{$self->{__stack}}, $self->values();
    push @{$self->{__stack_pos}}, $self->get_active_id();
}

# Replace the current values with the top of the stack
sub PopValues() {
    my $self = shift;
    if (!scalar(@{$self->{__stack}})) {
        return undef;
    }
    $self->values(pop @{$self->{__stack}});
    my $ypos = pop @{$self->{__stack_pos}};
    $self->{-ypos} = $ypos;
    $self->RenderLabels();
    $self->schedule_draw(1);
}

# Given objects for the Values, go through each one and ensure we have a
# label for it.  This can be repeated at any time the Values are updated
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
    $self->labels($labels);
    return 1;
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

