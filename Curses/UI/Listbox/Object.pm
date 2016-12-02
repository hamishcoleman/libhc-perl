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
    my $history_name = shift;

    push @{$self->{__stack}}, $self->get_active_id();
    push @{$self->{__stack}}, $self->{-yscrpos};
    push @{$self->{__stack}}, $self->values();
    push @{$self->{__stack}}, $history_name;
}

# Replace the current values with the top of the stack
sub PopValues() {
    my $self = shift;
    if (!scalar(@{$self->{__stack}})) {
        return undef;
    }

    # if we have a "history_name" for this item, we can save the last seen
    # position values for it
    my $history_name = pop @{$self->{__stack}};
    if (defined($history_name)) {
        $self->{__last_pos}{$history_name}{-yscrpos} = $self->{-yscrpos};
        $self->{__last_pos}{$history_name}{-ypos} = $self->{-ypos};
    }

    $self->values(pop @{$self->{__stack}});
    $self->{-yscrpos} = pop @{$self->{__stack}};
    $self->{-ypos} = pop @{$self->{__stack}};
    $self->RenderLabels();
    $self->schedule_draw(1);
}

# Given a "history_name", look for the last seen position values for it,
# and use them
sub UseLastSelection() {
    my $self = shift;
    my $history_name = shift;

    return if (!defined($self->{__last_pos}{$history_name}));

    $self->{-yscrpos} = $self->{__last_pos}{$history_name}{-yscrpos};
    $self->{-ypos} = $self->{__last_pos}{$history_name}{-ypos};
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

